
# Docker Gitlab Setup

## Environment Variables
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

## Gitlab Pages

### TLS/SSL Settings
#### Wildcard Certificates
To get SSL working with Gitlab Pages you will need Wildcard Certifcates 

* Install Certbot and generate Wildcard Certs. https://community.letsencrypt.org/t/getting-wildcard-certificates-with-certbot/56285
* Bind mount certs in container defined in `/gitlab/docker-compose.yml`

```
volumes:
  - /etc/letsencrypt:/etc/letsencrypt:ro
```

* Set Gitlab Pages settings in `/gitlab/docker-compose.yml`
```
 gitlab_pages['inplace_chroot'] = true
 pages_external_url 'https://${PAGES_HOST}'
 pages_nginx['redirect_http_to_https'] = true
 pages_nginx['ssl_certificate'] = "/etc/letsencrypt/live/${PAGES_HOST}/fullchain.pem"
 pages_nginx['ssl_certificate_key'] = "/etc/letsencrypt/live/${PAGES_HOST}/privkey.pem"
```
## Gitlab Registry

Settings in `/gitlab/docker-compose.yml`
```
gitlab_rails['registry_enabled'] = true
gitlab_rails['registry_path'] = "/var/opt/gitlab/gitlab-rails/shared/registry"
```
### Disable/Enable registry for all projects
If set to true the registry will be a standard feature for all projects. (This is the default)
```
 gitlab_rails['gitlab_default_projects_features_container_registry']= false # Make Registry a default feature for all projects
```
## Run Gitlab with Docker Compose
```
docker-compose up
```
# Gitlab Runner
The Gitlab Runner container can run on any host. In this case it's runnning on the same Docker Host as the gitlab instance.

### Environment Variables
* Copy `sample.env` and save as `.env`
* Add the domain of your Gitlab host.
* Add the Docker IP of your Gitlab container (Only needed if Gitlab Runner is on the same host as Gitlab)
```
GITLAB_HOST=gitlab.example.com
GITLAB_CONTAINER_IP=172.20.0.2
```

### Docker Compose
```
version: '3'
services:
  gitlab-runner:
    build: .
    container_name: gitlab-runner
    restart: always
    volumes:
      - /srv/gitlab-runner:/etc/gitlab-runner
      - ./config.toml:/etc/gitlab-runner/config.toml
      - /var/run/docker.sock:/var/run/docker.sock
    extra_hosts:
      - "${GITLAB_HOST}:${GITLAB_CONTAINER_IP}" # Only needed if running on the same host as Gitlab!
    network_mode: host

networks:
  default:
    external:
      name: gitlab_gitlab-net
```

### Example Docker in Docker Configuration

```
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "docker-runner"
  url = "example.com"
  token = ""
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = "docker:stable"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
    extra_hosts=["example.com:172.20.0.2"]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
```

* Copy `/gitlab-runner/config-sample.toml`, adjust the settings to your needs and save it as `config.toml`.
* The `external_hosts` entry is only needed if Gitlab Runner is running on the same Docker host as Gitlab.
* Retrieve the token from the `admin runners settings` page on your gitlab instance.

### Running on the same Docker host
* Make sure the gitlab container is up and runnning.
* Get the internal Docker IP of the gitlab container with `docker inspect gitlab`
* Adjust the IP under `external_hosts` in the `config.toml` - this has to be the internal Docker IP of the gitlab container!

### TLS/SSL
Gitlab Runner needs the Gitlab certificates to securly connect to Gitlab.
* Create a `certs` directory in `/gitlab-runner` (`/gitlab-runner/certs`).
* Copy the gitlab `yourdomain.crt` and `yourdomain.key`from the host directory `/srv/gitlab/ssl` to the `certs` folder you created beforehand.

### Run Gitlab Runner for the first time
`docker-compose up --build`
