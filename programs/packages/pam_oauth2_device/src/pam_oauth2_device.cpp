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
  const char *what() const throw() { return "Base Error"; }
};

class PamError : public BaseError {
 public:
  const char *what() const throw() { return "PAM Error"; }
};

class NetworkError : public BaseError {
 public:
  const char *what() const throw() { return "Network Error"; }
};

class TimeoutError : public NetworkError {
 public:
  const char *what() const throw() { return "Timeout Error"; }
};

class ResponseError : public NetworkError {
 public:
  const char *what() const throw() { return "Response Error"; }
};

std::string getQr(const char *text, const int ecc = 0, const int border = 1) {
  qrcodegen::QrCode::Ecc error_correction_level;
  switch (ecc) {
    case 1:
      error_correction_level = qrcodegen::QrCode::Ecc::MEDIUM;
      break;
    case 2:
      error_correction_level = qrcodegen::QrCode::Ecc::HIGH;
      break;
    default:
      error_correction_level = qrcodegen::QrCode::Ecc::LOW;
      break;
  }
  qrcodegen::QrCode qr =
      qrcodegen::QrCode::encodeText(text, error_correction_level);

  std::ostringstream oss;
  int i, j, size, top, bottom;
  size = qr.getSize();
  for (j = -border; j < size + border; j += 2) {
    for (i = -border; i < size + border; ++i) {
      top = qr.getModule(i, j);
      bottom = qr.getModule(i, j + 1);
      if (top && bottom) {
        oss << "\033[40;97m \033[0m";
      } else if (top && !bottom) {
        oss << "\033[40;97m\u2584\033[0m";
      } else if (!top && bottom) {
        oss << "\033[40;97m\u2580\033[0m";
      } else {
        oss << "\033[40;97m\u2588\033[0m";
      }
    }
    oss << std::endl;
  }
  return oss.str();
}

  std::string DeviceAuthResponse::get_prompt(const int qr_ecc = 0,
                                           const bool qr_show = true) {
  std::ostringstream prompt;
  prompt << "Authenticate at the identity provider using the following URL."
         << std::endl
         << std::endl;
  prompt << std::regex_replace(verification_uri, std::regex("\\s"), "%20")
         << std::endl;
  prompt << "With code: " << user_code << std::endl;
  prompt << std::endl << "Hit enter when you have authenticated." << std::endl;
  return prompt.str();
}

static size_t WriteCallback(void *contents, size_t size, size_t nmemb,
                            void *userp) {
  ((std::string *)userp)
      ->append(reinterpret_cast<char *>(contents), size * nmemb);
  return size * nmemb;
}

void make_authorization_request(const char *client_id,
                                const char *scope,
                                const char *device_endpoint, bool require_mfa,
                                DeviceAuthResponse *response) {
  CURL *curl;
  CURLcode res;
  std::string readBuffer;

  curl = curl_easy_init();
  if (!curl) {
    syslog(LOG_ERR, "make_authorization_request: curl initialization failed");
    throw NetworkError();
  }
  std::string params =
      std::string("client_id=") + client_id + "&scope=" + scope;
  if (require_mfa) {
    params += "&acr_values=https://refeds.org/profile/mfa";
    params +=
        " urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport";
  }
  curl_easy_setopt(curl, CURLOPT_URL, device_endpoint);
  curl_easy_setopt(curl, CURLOPT_POSTFIELDS, params.c_str());
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
  res = curl_easy_perform(curl);
  curl_easy_cleanup(curl);
  if (res != CURLE_OK) {
    syslog(LOG_ERR, "make_authorization_request: curl failed, rc=%d", res);
    throw NetworkError();
  }
  try {
    auto data = json::parse(readBuffer);
    response->user_code = data.at("user_code");
    response->device_code = data.at("device_code");
    response->verification_uri = data.at("verification_uri");
    if (data.find("verification_uri_complete") != data.end()) {
      response->verification_uri_complete =
          data.at("verification_uri_complete");
    }
  } catch (json::exception &e) {
    syslog(LOG_ERR, "make_authorization_request: json parse failed, error=%s",
           e.what());
    throw ResponseError();
  }
}

void poll_for_token(const char *client_id,
                    const char *token_endpoint, const char *device_code,
                    std::string *token) {
  int timeout = 900, interval = 3;
  CURL *curl;
  CURLcode res;
  json data;
  std::ostringstream oss;
  std::string params;

  oss << "grant_type=urn:ietf:params:oauth:grant-type:device_code"
      << "&device_code=" << device_code << "&client_id=" << client_id;
  params = oss.str();

  while (true) {
    timeout -= interval;
    if (timeout < 0) {
      syslog(LOG_ERR, "poll_for_token: timeout %ds exceeded", timeout);
      throw TimeoutError();
    }
    std::string readBuffer;
    std::this_thread::sleep_for(std::chrono::seconds(interval));
    curl = curl_easy_init();
    if (!curl) {
      syslog(LOG_ERR, "poll_for_token: curl initialization failed");
      throw NetworkError();
    }
    curl_easy_setopt(curl, CURLOPT_URL, token_endpoint);
    curl_easy_setopt(curl, CURLOPT_USERNAME, client_id);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, params.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

    res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);
    if (res != CURLE_OK) {
      syslog(LOG_ERR, "poll_for_token: curl failed, rc=%d", res);
      throw NetworkError();
    }
    try {
      data = json::parse(readBuffer);
      if (data["error"].empty()) {
        token->assign(data.at("access_token"));
        break;
      } else if (data["error"] == "authorization_pending") {
        // Do nothing
      } else if (data["error"] == "slow_down") {
        ++interval;
      } else {
        syslog(LOG_ERR, "poll_for_token: unknown response '%s'",
               ((std::string)data["error"]).c_str());
        throw ResponseError();
      }
    } catch (json::exception &e) {
      syslog(LOG_ERR, "poll_for_token: json parse failed, error=%s", e.what());
      throw ResponseError();
    }
  }
}

void get_userinfo(const char *userinfo_endpoint, const char *token,
                  const json &username_attribute, Userinfo *userinfo) {
  CURL *curl;
  CURLcode res;
  std::string readBuffer;

  curl = curl_easy_init();
  if (!curl) {
    syslog(LOG_ERR, "get_userinfo: curl initialization failed");
    throw NetworkError();
  }
  curl_easy_setopt(curl, CURLOPT_URL, userinfo_endpoint);
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

  std::string auth_header = "Authorization: Bearer " + std::string(token);
  struct curl_slist *headers = nullptr;
  headers = curl_slist_append(headers, auth_header.c_str());
  curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

  res = curl_easy_perform(curl);
  curl_easy_cleanup(curl);
  curl_slist_free_all(headers);  // free curl header list
  if (res != CURLE_OK) {
    syslog(LOG_ERR, "get_userinfo: curl failed, rc=%d", res);
    throw NetworkError();
  }

  try {
    auto data = json::parse(readBuffer);
    userinfo->sub = data.at("sub");
    size_t pipe_pos = userinfo->sub.find('|');
    std::string sub_prefix = (pipe_pos != std::string::npos) ?
                             userinfo->sub.substr(0, pipe_pos) :
                             userinfo->sub;

    // Look up the username attribute key from the JSON mapping
    std::string attr_key = username_attribute.value(sub_prefix, "sub");
    userinfo->username = data.at(attr_key);
    userinfo->name = data.at("name");
    userinfo->acr = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport";
    if (data.find("acr") != data.end()) {
      userinfo->acr = data.at("acr");
    }
  } catch (json::exception &e) {
    syslog(LOG_ERR, "get_userinfo: json parse failed, error=%s", e.what());
    throw ResponseError();
  }
}

void show_prompt(pam_handle_t *pamh, const int qr_error_correction_level,
                 const bool qr_show, DeviceAuthResponse *device_auth_response) {
  int pam_err;
  char *response;
  struct pam_conv *conv;
  struct pam_message msg;
  const struct pam_message *msgp;
  struct pam_response *resp;
  std::string prompt;

  pam_err = pam_get_item(pamh, PAM_CONV, (const void **)&conv);
  if (pam_err != PAM_SUCCESS) {
    syslog(LOG_ERR, "show_prompt: pam_get_item failed, rc=%d", pam_err);
    throw PamError();
  }
  prompt = device_auth_response->get_prompt(qr_error_correction_level, qr_show);
  msg.msg_style = PAM_PROMPT_ECHO_OFF;
  msg.msg = prompt.c_str();
  msgp = &msg;
  response = NULL;
  pam_err = (*conv->conv)(1, &msgp, &resp, conv->appdata_ptr);
  if (resp != NULL) {
    if (pam_err == PAM_SUCCESS) {
      response = resp->resp;
    } else {
      free(resp->resp);
    }
    free(resp);
  }
  if (response) free(response);
}

bool local_user_exists(const std::string& username) {
  return getpwnam(username.c_str()) != nullptr;
}

int safe_return(int rc) {
  closelog();
  return rc;
}

/* expected hook */
PAM_EXTERN int pam_sm_setcred(pam_handle_t *pamh, int flags, int argc,
                              const char **argv) {
  return PAM_SUCCESS;
}

/* expected hook */
PAM_EXTERN int pam_sm_acct_mgmt(pam_handle_t *pamh, int flags, int argc,
                                const char **argv) {
  return PAM_SUCCESS;
}

static void cleanup_free(pam_handle_t *pamh, void *data, int error_status) {
  (void)pamh;
  (void)error_status;
  free(data);
}

PAM_EXTERN int pam_sm_authenticate(pam_handle_t *pamh, int flags, int argc,
                                   const char **argv) {
    Config config;
    DeviceAuthResponse device_auth_response;
    Userinfo userinfo;
    std::string token;

    openlog("pam_oauth2_device", LOG_PID | LOG_NDELAY, LOG_AUTH);

    try {
        (argc > 0) ? config.load(argv[0])
                   : config.load("/etc/pam_oauth2_device/config.json");
    } catch (json::exception &e) {
        syslog(LOG_ERR, "cannot load configuration file: %s", e.what());
        return PAM_AUTH_ERR;
    }

    try {
        // Start OAuth device flow
        make_authorization_request(
            config.client_id.c_str(),
            config.scope.c_str(),
            config.device_endpoint.c_str(),
            config.require_mfa,
            &device_auth_response
        );

        show_prompt(pamh, config.qr_error_correction_level, config.qr_show,
                    &device_auth_response);

        poll_for_token(config.client_id.c_str(),
                       config.token_endpoint.c_str(),
                       device_auth_response.device_code.c_str(),
                       &token);

        // Pull the username directly from OAuth
        get_userinfo(config.userinfo_endpoint.c_str(),
                     token.c_str(),
                     config.username_attribute,
                     &userinfo);

    } catch (PamError &e) {
        return PAM_SYSTEM_ERR;
    } catch (TimeoutError &e) {
        return PAM_AUTH_ERR;
    } catch (NetworkError &e) {
        return PAM_AUTH_ERR;
    }

    // Store the OAuth username for the session phase
    pam_set_data(
        pamh,
        "pam_oauth2_device_username",
        strdup(userinfo.username.c_str()),
        cleanup_free
    );

    return PAM_SUCCESS;
}

void create_local_user(const std::string& username) {
  pid_t pid = fork();
  if (pid < 0) {
    syslog(LOG_ERR, "fork failed while creating user %s", username.c_str());
    throw PamError();
  }

  if (pid == 0) {
    execl(
      "/run/current-system/sw/bin/useradd",
      "useradd",
      "-m",                 // create home directory
      "-s", "/bin/bash",    // default shell
      username.c_str(),
      (char*)nullptr
    );
    _exit(127); // exec failed
  }

  int status;
  if (waitpid(pid, &status, 0) < 0) {
    syslog(LOG_ERR, "waitpid failed while creating user %s", username.c_str());
    throw PamError();
  }

  if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
    syslog(LOG_ERR, "useradd failed for %s (exit=%d)",
           username.c_str(),
           WEXITSTATUS(status));
    throw PamError();
  }
}

void set_user_password(const std::string& username,
                       const std::string& password) {
  int pipefd[2];
  if (pipe(pipefd) != 0) {
    syslog(LOG_ERR, "pipe failed while setting password for %s",
           username.c_str());
    throw PamError();
  }

  pid_t pid = fork();
  if (pid < 0) {
    syslog(LOG_ERR, "fork failed while setting password for %s",
           username.c_str());
    close(pipefd[0]);
    close(pipefd[1]);
    throw PamError();
  }

  if (pid == 0) {
    // child
    dup2(pipefd[0], STDIN_FILENO);
    close(pipefd[1]);

    execl(
      "/run/current-system/sw/bin/chpasswd",
      "chpasswd",
      (char*)nullptr
    );
    _exit(127);
  }

  // parent
  close(pipefd[0]);

  std::string line = username + ":" + password + "\n";
  ssize_t written = write(pipefd[1], line.data(), line.size());
  close(pipefd[1]);

  if (written != (ssize_t)line.size()) {
    syslog(LOG_ERR, "failed writing password for %s", username.c_str());
    throw PamError();
  }

  int status;
  if (waitpid(pid, &status, 0) < 0) {
    syslog(LOG_ERR, "waitpid failed while setting password for %s",
           username.c_str());
    throw PamError();
  }

  if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
    syslog(LOG_ERR, "chpasswd failed for %s (exit=%d)",
           username.c_str(),
           WEXITSTATUS(status));
    throw PamError();
  }
}

std::string prompt_password(pam_handle_t *pamh, const char *prompt) {
  struct pam_conv *conv = nullptr;
  struct pam_message msg;
  const struct pam_message *msgp;
  struct pam_response *resp = nullptr;

  int pam_err = pam_get_item(pamh, PAM_CONV, (const void **)&conv);
  if (pam_err != PAM_SUCCESS || !conv || !conv->conv) {
    syslog(LOG_ERR, "prompt_password: no PAM conversation");
    throw PamError();
  }

  msg.msg_style = PAM_PROMPT_ECHO_OFF;
  msg.msg = prompt;
  msgp = &msg;

  pam_err = conv->conv(1, &msgp, &resp, conv->appdata_ptr);
  if (pam_err != PAM_SUCCESS || !resp || !resp->resp) {
    if (resp) free(resp);
    syslog(LOG_ERR, "prompt_password: conversation failed");
    throw PamError();
  }

  std::string password(resp->resp);

  free(resp->resp);
  free(resp);

  return password;
}

PAM_EXTERN int pam_sm_open_session(pam_handle_t *pamh,
                                   int flags,
                                   int argc,
                                   const char **argv) {
    const void* data = nullptr;

    // Get the username from pam_sm_authenticate
    if (pam_get_data(pamh, "pam_oauth2_device_username", &data) != PAM_SUCCESS) {
        syslog(LOG_INFO, "pam_sm_open_session: no OAuth username stored, skipping");
        return PAM_SUCCESS; // nothing to do
    }

    const char* username = static_cast<const char*>(data);
    openlog("pam_oauth2_device", LOG_PID | LOG_NDELAY, LOG_AUTH);

    syslog(LOG_INFO, "pam_sm_open_session: starting session for user '%s'", username);

    try {
        if (!local_user_exists(username)) {
            syslog(LOG_INFO, "User '%s' does not exist, creating...", username);

            // Step 1: create user
            create_local_user(username);

            // Step 2: verify user was created
            if (!local_user_exists(username)) {
                syslog(LOG_ERR, "User '%s' still does not exist after create_local_user!", username);
                return PAM_SESSION_ERR;
            }
            syslog(LOG_INFO, "User '%s' successfully created", username);

            // Step 3: set a locked password
            std::string locked_pw = "!" + std::string(username);
            set_user_password(username, locked_pw);

            syslog(LOG_INFO, "User '%s' password locked", username);
        } else {
            syslog(LOG_INFO, "User '%s' already exists, no action needed", username);
        }
    } catch (const std::exception &e) {
        syslog(LOG_ERR, "pam_sm_open_session: exception while creating user '%s': %s",
               username, e.what());
        return PAM_SESSION_ERR;
    } catch (...) {
        syslog(LOG_ERR, "pam_sm_open_session: unknown error while creating user '%s'", username);
        return PAM_SESSION_ERR;
    }

    syslog(LOG_INFO, "pam_sm_open_session: completed session setup for '%s'", username);
    return PAM_SUCCESS;
}

PAM_EXTERN int pam_sm_close_session(pam_handle_t *pamh,
                                    int flags,
                                    int argc,
                                    const char **argv) {
    (void)pamh;  // avoid unused parameter warnings
    (void)flags;
    (void)argc;
    (void)argv;
    return PAM_SUCCESS;
}
