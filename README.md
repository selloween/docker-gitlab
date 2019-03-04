
# Docker Gitlab Setup

## Set Environment Variables
Copy `/gitlab/sample.env`, adjust the variables and save the file as `.env`

```
VIRTUAL_HOST=example.com
EXTERNAL_URL=https://example.com
LOGIN_LABEL='EXAMPLE LOGIN'
ASSERTION_CONSUMER_SERVICE_URL='https://example-gitlab.com/users/auth/saml/callback'
IDP_CERT_FINGERPRINT=''
IDP_SSO_TARGET_URL='https://example-keycloak/auth/realms/example-realm/protocol/saml/clients/gitlab'
ISSUER='gitlab'
PAGES_HOST=pages.example.com
REGISTRY_HOST=registry.example.com
REGISTRY_PORT=5000
```
### Gitlab Environment Variables
* `VIRTUAL_HOST` - The domain of your gitlab host.
* `EXTERNAL_URL` - The full external URL of your gitlab host.

### Keycloak Environment Variables
These variables can be omitted if you don't use Keycloak as Authentication Provider

* `LOGIN_LABEL` - Text of the Login Button for Single Sign On with Keycloak as Authentication Provider
* `ASSERTION_CONSUMER_SERVICE_URL`- This is the SAML callback URL of Keycloak
* `IDP_CERT_FINGERPRINT` - The Keycloak Realm Cert retrieved from the Realm Settings Page. Use https://www.samltool.com/fingerprint.php to convert the `X.509 public certificate` to a `fingerprint`.
* `IDP_SSO_TARGET_URL` - The Identity Provide Single Sign On URL
* `ISSUER` - defines the client requesting access - in this case the client is called `gitlab`

### Gitlab Pages Environment Variables
* `PAGES_HOST` - the pages domain used by gitlab to serve pages

### Gitlab Docker Registry Environment Variables
* `REGISTRY_HOST` - Domain of the registry, can be omitted if you use the domain of gitlab and a different port instead
* `REGISTRY_PORT` - The port of the registry - only needed if you don't use a dedicated registry domain.


