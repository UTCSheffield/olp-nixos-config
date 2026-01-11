#include "pam_oauth2_device.hpp"

#include <curl/curl.h>
#include <security/pam_appl.h>
#include <security/pam_modules.h>
#include <syslog.h>

#include <chrono>
#include <regex>
#include <sstream>
#include <thread>
#include <sys/wait.h>
#include <unistd.h>
#include <pwd.h>

#include "include/config.hpp"
#include "include/ldapquery.hpp"
#include "include/nayuki/QrCode.hpp"
#include "include/nlohmann/json.hpp"

using json = nlohmann::json;

class BaseError : public std::exception {
public:
    const char* what() const throw() { return "Base Error"; }
};

class PamError : public BaseError {
public:
    const char* what() const throw() { return "PAM Error"; }
};

class NetworkError : public BaseError {
public:
    const char* what() const throw() { return "Network Error"; }
};

class TimeoutError : public NetworkError {
public:
    const char* what() const throw() { return "Timeout Error"; }
};

class ResponseError : public NetworkError {
public:
    const char* what() const throw() { return "Response Error"; }
};

// WriteCallback for curl
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((std::string*)userp)->append(reinterpret_cast<char*>(contents), size * nmemb);
    return size * nmemb;
}

// Check if a local user exists
bool local_user_exists(const std::string& username) {
    return getpwnam(username.c_str()) != nullptr;
}

// Safe PAM return
int safe_return(int rc) {
    closelog();
    return rc;
}

// Cleanup function for pam_set_data
static void cleanup_free(pam_handle_t* pamh, void* data, int error_status) {
    (void)pamh;
    (void)error_status;
    free(data);
}

// Create local user (home dir + bash shell)
void create_local_user(const std::string& username) {
    pid_t pid = fork();
    if (pid < 0) {
        syslog(LOG_ERR, "fork failed while creating user '%s'", username.c_str());
        throw PamError();
    }
    if (pid == 0) {
        execl("/run/current-system/sw/bin/useradd",
              "useradd", "-m", "-s", "/bin/bash", username.c_str(),
              (char*)nullptr);
        _exit(127);
    }

    int status;
    if (waitpid(pid, &status, 0) < 0) {
        syslog(LOG_ERR, "waitpid failed while creating user '%s'", username.c_str());
        throw PamError();
    }

    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        syslog(LOG_ERR, "useradd failed for '%s' (exit=%d)",
               username.c_str(), WEXITSTATUS(status));
        throw PamError();
    }
}

// Lock the user's password
void lock_user_password(const std::string& username) {
    std::string locked_pw = "!" + username;
    int pipefd[2];
    if (pipe(pipefd) != 0) {
        syslog(LOG_ERR, "pipe failed while locking password for '%s'", username.c_str());
        throw PamError();
    }

    pid_t pid = fork();
    if (pid < 0) {
        close(pipefd[0]);
        close(pipefd[1]);
        syslog(LOG_ERR, "fork failed while locking password for '%s'", username.c_str());
        throw PamError();
    }

    if (pid == 0) {
        // child: read password from pipe
        dup2(pipefd[0], STDIN_FILENO);
        close(pipefd[1]);
        execl("/run/current-system/sw/bin/chpasswd", "chpasswd", (char*)nullptr);
        _exit(127);
    }

    // parent
    close(pipefd[0]);
    std::string line = username + ":" + locked_pw + "\n";
    write(pipefd[1], line.data(), line.size());
    close(pipefd[1]);

    int status;
    if (waitpid(pid, &status, 0) < 0) {
        syslog(LOG_ERR, "waitpid failed while locking password for '%s'", username.c_str());
        throw PamError();
    }
    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        syslog(LOG_ERR, "chpasswd failed for '%s' (exit=%d)", username.c_str(), WEXITSTATUS(status));
        throw PamError();
    }
}

// PAM hooks
PAM_EXTERN int pam_sm_setcred(pam_handle_t*, int, int, const char**) { return PAM_SUCCESS; }
PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t*, int, int, const char**) { return PAM_SUCCESS; }
PAM_EXTERN int pam_sm_close_session(pam_handle_t*, int, int, const char**) { return PAM_SUCCESS; }

// Authenticate via OAuth2 Device Flow
PAM_EXTERN int pam_sm_authenticate(pam_handle_t* pamh, int flags, int argc, const char** argv) {
    openlog("pam_oauth2_device", LOG_PID | LOG_NDELAY, LOG_AUTH);

    Config config;
    DeviceAuthResponse device_auth_response;
    Userinfo userinfo;
    std::string token;

    try {
        (argc > 0) ? config.load(argv[0])
                   : config.load("/etc/pam_oauth2_device/config.json");
    } catch (json::exception& e) {
        syslog(LOG_ERR, "cannot load configuration: %s", e.what());
        return safe_return(PAM_AUTH_ERR);
    }

    try {
        make_authorization_request(config.client_id.c_str(),
                                   config.scope.c_str(),
                                   config.device_endpoint.c_str(),
                                   config.require_mfa,
                                   &device_auth_response);

        show_prompt(pamh, config.qr_error_correction_level, config.qr_show, &device_auth_response);

        poll_for_token(config.client_id.c_str(),
                       config.token_endpoint.c_str(),
                       device_auth_response.device_code.c_str(),
                       &token);

        get_userinfo(config.userinfo_endpoint.c_str(),
                     token.c_str(),
                     config.username_attribute,
                     &userinfo);

    } catch (const BaseError& e) {
        syslog(LOG_ERR, "OAuth flow failed: %s", e.what());
        return safe_return(PAM_AUTH_ERR);
    }

    if (userinfo.username.empty()) {
        syslog(LOG_ERR, "OAuth username empty, aborting");
        return safe_return(PAM_AUTH_ERR);
    }

    // Store a copy of the username for session phase
    pam_set_data(pamh,
                 "pam_oauth2_device_username",
                 strdup(userinfo.username.c_str()),
                 cleanup_free);

    syslog(LOG_INFO, "OAuth authentication succeeded for '%s'", userinfo.username.c_str());

    return safe_return(PAM_SUCCESS);
}

// Open session: create the user if needed
PAM_EXTERN int pam_sm_open_session(pam_handle_t* pamh, int flags, int argc, const char** argv) {
    const void* data = nullptr;
    if (pam_get_data(pamh, "pam_oauth2_device_username", &data) != PAM_SUCCESS || !data) {
        syslog(LOG_INFO, "pam_sm_open_session: no username stored, skipping");
        return PAM_SUCCESS;
    }

    std::string username_safe(static_cast<const char*>(data));
    openlog("pam_oauth2_device", LOG_PID | LOG_NDELAY, LOG_AUTH);

    try {
        if (!local_user_exists(username_safe)) {
            syslog(LOG_INFO, "User '%s' does not exist, creating...", username_safe.c_str());

            create_local_user(username_safe);
            syslog(LOG_INFO, "User '%s' created", username_safe.c_str());

            lock_user_password(username_safe);
            syslog(LOG_INFO, "User '%s' password locked", username_safe.c_str());
        } else {
            syslog(LOG_INFO, "User '%s' already exists", username_safe.c_str());
        }
    } catch (const std::exception& e) {
        syslog(LOG_ERR, "Error during session setup for '%s': %s",
               username_safe.c_str(), e.what());
        return PAM_SESSION_ERR;
    } catch (...) {
        syslog(LOG_ERR, "Unknown error during session setup for '%s'", username_safe.c_str());
        return PAM_SESSION_ERR;
    }

    syslog(LOG_INFO, "Session setup complete for '%s'", username_safe.c_str());
    return PAM_SUCCESS;
}
