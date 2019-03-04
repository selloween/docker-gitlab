FROM gitlab/gitlab-runner:latest

RUN mkdir -p /etc/gitlab-runner/certs
COPY ./certs/{$GITLAB_HOST}.crt /etc/gitlab-runner/certs/{$GITLAB_HOST}.crt
COPY ./certs/{$GITLAB_HOST}.key /etc/gitlab-runner/certs/{$GITLAB_HOST}.key

