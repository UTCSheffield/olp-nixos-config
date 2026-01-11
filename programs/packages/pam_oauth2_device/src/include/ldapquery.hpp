#ifndef PAM_OAUTH2_DEVICE_LDAPQUERY_H
#define PAM_OAUTH2_DEVICE_LDAPQUERY_H

#define LDAPQUERY_ERROR -1
#define LDAPQUERY_TRUE 1
#define LDAPQUERY_FALSE 0

#include <string>

int ldap_check_attr(const std::string &host, const std::string &basedn,
                    const std::string &user, const std::string &passwd,
                    const std::string &filter, const std::string &attr,
                    const std::string &value);

#endif  // PAM_OAUTH2_DEVICE_LDAPQUERY_H
