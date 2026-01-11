#include "ldapquery.hpp"

#include <ldap.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <string>

int ldap_check_attr(const std::string &host, const std::string &basedn,
                    const std::string &user, const std::string &passwd,
                    const std::string &filter, const std::string &attr,
                    const std::string &value) {
  LDAP *ld;
  LDAPMessage *res, *msg;
  BerElement *ber;
  BerValue *servercredp;
  char *a, *passwd_local;
  int rc, i;
  struct berval cred;
  struct berval **vals;
  char *attr_local = NULL;
  char *attrs[] = {attr_local, NULL};
  const int ldap_version = LDAP_VERSION3;

  if (ldap_initialize(&ld, host.c_str()) != LDAP_SUCCESS) {
    return LDAPQUERY_ERROR;
  }

  if (ldap_set_option(ld, LDAP_OPT_PROTOCOL_VERSION, &ldap_version) !=
      LDAP_SUCCESS) {
    return LDAPQUERY_ERROR;
  }

  passwd_local = new char[passwd.length() + 1];
  snprintf(passwd_local, passwd.length() + 1, "%s", passwd.c_str());
  cred.bv_val = passwd_local;
  cred.bv_len = passwd.length();
  rc = ldap_sasl_bind_s(ld, user.c_str(), LDAP_SASL_SIMPLE, &cred, NULL, NULL,
                        &servercredp);
  delete[] passwd_local;
  if (rc != LDAP_SUCCESS) {
    return LDAPQUERY_ERROR;
  }

  attr_local = strdup(attr.c_str());
  rc = ldap_search_ext_s(ld, basedn.c_str(), LDAP_SCOPE_SUBTREE, filter.c_str(),
                         attrs, 0, NULL, NULL, NULL, 0, &res);
  free(attr_local);
  if (rc != LDAP_SUCCESS) {
    ldap_msgfree(res);
    ldap_unbind_ext_s(ld, NULL, NULL);
    return LDAPQUERY_ERROR;
  }

  rc = LDAPQUERY_FALSE;
  for (msg = ldap_first_message(ld, res); msg != NULL;
       msg = ldap_next_message(ld, msg)) {
    switch (ldap_msgtype(msg)) {
      case LDAP_RES_SEARCH_ENTRY:
        for (a = ldap_first_attribute(ld, res, &ber); a != NULL;
             a = ldap_next_attribute(ld, res, ber)) {
          if ((vals = ldap_get_values_len(ld, res, a)) != NULL) {
            for (i = 0; vals[i] != NULL; ++i) {
              if (strcmp(a, attr.c_str()) == 0) {
                if (strcmp(vals[i]->bv_val, value.c_str()) == 0) {
                  rc = LDAPQUERY_TRUE;
                }
              }
            }
            ldap_value_free_len(vals);
          }
          ldap_memfree(a);
        }
        if (ber != NULL) {
          ber_free(ber, 0);
        }
        break;
      default:
        break;
    }
  }

  ldap_msgfree(res);
  ldap_unbind_ext_s(ld, NULL, NULL);
  return rc;
}
