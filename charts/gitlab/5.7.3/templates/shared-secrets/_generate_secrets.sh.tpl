# vim: set filetype=sh:

namespace={{ .Release.Namespace }}
release={{ .Release.Name }}
env={{ index .Values "shared-secrets" "env" }}

pushd $(mktemp -d)

# Args pattern, length
function gen_random(){
  head -c 4096 /dev/urandom | LC_CTYPE=C tr -cd $1 | head -c $2
}

# Args: yaml file, search path
function fetch_rails_value(){
  local value=$(yq read $1 "${2}")
  # Don't return null values
  if [ "${value}" != "null" ]; then echo "${value}"; fi
}

# Args: secretname
function label_secret(){
  local secret_name=$1
{{ if not .Values.global.application.create -}}
  # Remove application labels if they exist
  kubectl --namespace=$namespace label \
    secret $secret_name $(echo '{{ include "gitlab.application.labels" . | replace ": " "=" | replace "\r\n" " " | replace "\n" " " }}' | sed -E 's/=[^ ]*/-/g')
{{ end }}
  kubectl --namespace=$namespace label \
    --overwrite \
    secret $secret_name {{ include "gitlab.standardLabels" . | replace ": " "=" | replace "\r\n" " " | replace "\n" " " }} {{ include "gitlab.commonLabels" . | replace ": " "=" | replace "\r\n" " " | replace "\n" " " }}
}

# Args: secretname, args
function generate_secret_if_needed(){
  local secret_args=( "${@:2}")
  local secret_name=$1

  if ! $(kubectl --namespace=$namespace get secret $secret_name > /dev/null 2>&1); then
    kubectl --namespace=$namespace create secret generic $secret_name ${secret_args[@]}
  else
    echo "secret \"$secret_name\" already exists."

    for arg in "${secret_args[@]}"; do
      local from=$(echo -n ${arg} | cut -d '=' -f1)

      if [ -z "${from##*literal*}" ]; then
        local key=$(echo -n ${arg} | cut -d '=' -f2)
        local desiredValue=$(echo -n ${arg} | cut -d '=' -f3-)
        local flags="--namespace=$namespace --allow-missing-template-keys=false"

        if ! $(kubectl $flags get secret $secret_name -ojsonpath="{.data.${key}}" > /dev/null 2>&1); then
          echo "key \"${key}\" does not exist. patching it in."

          if [ "${desiredValue}" != "" ]; then
            desiredValue=$(echo -n "${desiredValue}" | base64 -w 0)
          fi

          kubectl --namespace=$namespace patch secret ${secret_name} -p "{\"data\":{\"$key\":\"${desiredValue}\"}}"
        fi
      fi
    done
  fi

  label_secret $secret_name
}

# Initial root password
generate_secret_if_needed {{ template "gitlab.migrations.initialRootPassword.secret" . }} --from-literal={{ template "gitlab.migrations.initialRootPassword.key" . }}=$(gen_random 'a-zA-Z0-9' 64)

{{ if and (not .Values.global.redis.host) .Values.global.redis.password.enabled -}}
# Redis password
generate_secret_if_needed {{ template "gitlab.redis.password.secret" . }} --from-literal={{ template "gitlab.redis.password.key" . }}=$(gen_random 'a-zA-Z0-9' 64)
{{ end }}

{{ if not .Values.global.psql.host -}}
# Postgres password
generate_secret_if_needed {{ template "gitlab.psql.password.secret" . }} --from-literal=postgresql-password=$(gen_random 'a-zA-Z0-9' 64) --from-literal=postgresql-postgres-password=$(gen_random 'a-zA-Z0-9' 64)
{{ end }}

# Gitlab shell
generate_secret_if_needed {{ template "gitlab.gitlab-shell.authToken.secret" . }} --from-literal={{ template "gitlab.gitlab-shell.authToken.key" . }}=$(gen_random 'a-zA-Z0-9' 64)

# Gitaly secret
generate_secret_if_needed {{ template "gitlab.gitaly.authToken.secret" . }} --from-literal={{ template "gitlab.gitaly.authToken.key" . }}=$(gen_random 'a-zA-Z0-9' 64)

{{ if .Values.global.minio.enabled -}}
# Minio secret
generate_secret_if_needed {{ template "gitlab.minio.credentials.secret" . }} --from-literal=accesskey=$(gen_random 'a-zA-Z0-9' 64) --from-literal=secretkey=$(gen_random 'a-zA-Z0-9' 64)
{{ end }}

# Gitlab runner secret
generate_secret_if_needed {{ template "gitlab.gitlab-runner.registrationToken.secret" . }} --from-literal=runner-registration-token=$(gen_random 'a-zA-Z0-9' 64) --from-literal=runner-token=""

# GitLab Pages API secret
{{ if or (eq $.Values.global.pages.enabled true) (not (empty $.Values.global.pages.host)) }}
generate_secret_if_needed {{ template "gitlab.pages.apiSecret.secret" . }} --from-literal={{ template "gitlab.pages.apiSecret.key" . }}=$(gen_random 'a-zA-Z0-9' 32 | base64)
{{ end }}

# GitLab Pages auth secret for hashing cookie store when using access control
{{ if and (eq $.Values.global.pages.enabled true) (eq $.Values.global.pages.accessControl true) }}
generate_secret_if_needed {{ template "gitlab.pages.authSecret.secret" . }} --from-literal={{ template "gitlab.pages.authSecret.key" . }}=$(gen_random 'a-zA-Z0-9' 64 | base64 -w 0)
{{ end }}

# GitLab Pages OAuth secret
{{ if and (eq $.Values.global.pages.enabled true) (eq $.Values.global.pages.accessControl true) }}
generate_secret_if_needed {{ template "oauth.gitlab-pages.secret" . }} --from-literal={{ template "oauth.gitlab-pages.appIdKey" . }}=$(gen_random 'a-zA-Z0-9' 64) --from-literal={{ template "oauth.gitlab-pages.appSecretKey" . }}=$(gen_random 'a-zA-Z0-9' 64)
{{ end }}

{{ if .Values.global.kas.enabled -}}
# Gitlab-kas secret
generate_secret_if_needed {{ template "gitlab.kas.secret" . }} --from-literal={{ template "gitlab.kas.key" . }}=$(gen_random 'a-zA-Z0-9' 32 | base64)

# Gitlab-kas private API secret
generate_secret_if_needed {{ template "gitlab.kas.privateApi.secret" . }} --from-literal={{ template "gitlab.kas.privateApi.key" . }}=$(gen_random 'a-zA-Z0-9' 32 | base64)
{{ end }}

{{ if .Values.global.appConfig.incomingEmail.enabled -}}
# Gitlab-mailroom incomingEmail webhook secret
generate_secret_if_needed {{ template "gitlab.appConfig.incomingEmail.authToken.secret" . }} --from-literal={{ template "gitlab.appConfig.incomingEmail.authToken.key" . }}=$(gen_random 'a-zA-Z0-9' 32 | base64)
{{ end }}

{{ if .Values.global.appConfig.serviceDeskEmail.enabled -}}
# Gitlab-mailroom serviceDeskEmail webhook secret
generate_secret_if_needed {{ template "gitlab.appConfig.serviceDeskEmail.authToken.secret" . }} --from-literal={{ template "gitlab.appConfig.serviceDeskEmail.authToken.key" . }}=$(gen_random 'a-zA-Z0-9' 32 | base64)
{{ end }}

# Registry certificates
mkdir -p certs
openssl req -new -newkey rsa:4096 -subj "/CN=gitlab-issuer" -nodes -x509 -keyout certs/registry-example-com.key -out certs/registry-example-com.crt -days 3650
generate_secret_if_needed {{ template "gitlab.registry.certificate.secret" . }} --from-file=registry-auth.key=certs/registry-example-com.key --from-file=registry-auth.crt=certs/registry-example-com.crt

# config/secrets.yaml
if [ -n "$env" ]; then
  rails_secret={{ template "gitlab.rails-secrets.secret" . }}

  # Fetch the values from the existing secret if it exists
  if $(kubectl --namespace=$namespace get secret $rails_secret > /dev/null 2>&1); then
    kubectl --namespace=$namespace get secret $rails_secret -o jsonpath="{.data.secrets\.yml}" | base64 --decode > secrets.yml
    secret_key_base=$(fetch_rails_value secrets.yml "${env}.secret_key_base")
    otp_key_base=$(fetch_rails_value secrets.yml "${env}.otp_key_base")
    db_key_base=$(fetch_rails_value secrets.yml "${env}.db_key_base")
    openid_connect_signing_key=$(fetch_rails_value secrets.yml "${env}.openid_connect_signing_key")
    ci_jwt_signing_key=$(fetch_rails_value secrets.yml "${env}.ci_jwt_signing_key")
    encrypted_settings_key_base=$(fetch_rails_value secrets.yml "${env}.encrypted_settings_key_base")
  fi;

  # Generate defaults for any unset secrets
  secret_key_base="${secret_key_base:-$(gen_random 'a-f0-9' 128)}" # equavilent to secureRandom.hex(64)
  otp_key_base="${otp_key_base:-$(gen_random 'a-f0-9' 128)}" # equavilent to secureRandom.hex(64)
  db_key_base="${db_key_base:-$(gen_random 'a-f0-9' 128)}" # equavilent to secureRandom.hex(64)
  openid_connect_signing_key="${openid_connect_signing_key:-$(openssl genrsa 2048)}"
  ci_jwt_signing_key="${ci_jwt_signing_key:-$(openssl genrsa 2048)}"
  encrypted_settings_key_base="${encrypted_settings_key_base:-$(gen_random 'a-f0-9' 128)}" # equavilent to secureRandom.hex(64)

  # Update the existing secret
  cat << EOF > rails-secrets.yml
apiVersion: v1
kind: Secret
metadata:
  name: $rails_secret
type: Opaque
stringData:
  secrets.yml: |-
    $env:
      secret_key_base: $secret_key_base
      otp_key_base: $otp_key_base
      db_key_base: $db_key_base
      encrypted_settings_key_base: $encrypted_settings_key_base
      openid_connect_signing_key: |
$(echo "${openid_connect_signing_key}" | awk '{print "        " $0}')
      ci_jwt_signing_key: |
$(echo "${ci_jwt_signing_key}" | awk '{print "        " $0}')
EOF
  kubectl --validate=false --namespace=$namespace apply -f rails-secrets.yml
  label_secret $rails_secret
fi

# Shell ssh host keys
ssh-keygen -A
mkdir -p host_keys
cp /etc/ssh/ssh_host_* host_keys/
generate_secret_if_needed {{ template "gitlab.gitlab-shell.hostKeys.secret" . }} --from-file host_keys

# Gitlab-workhorse secret
generate_secret_if_needed {{ template "gitlab.workhorse.secret" . }} --from-literal={{ template "gitlab.workhorse.key" . }}=$(gen_random 'a-zA-Z0-9' 32 | base64)

# Registry http.secret secret
generate_secret_if_needed {{ template "gitlab.registry.httpSecret.secret" . }} --from-literal={{ template "gitlab.registry.httpSecret.key" . }}=$(gen_random 'a-z0-9' 128 | base64 -w 0)

# Container Registry notification_secret
generate_secret_if_needed {{ template "gitlab.registry.notificationSecret.secret" . }} --from-literal={{ template "gitlab.registry.notificationSecret.key" . }}=[\"$(gen_random 'a-zA-Z0-9' 32)\"]

{{ if .Values.global.grafana.enabled -}}
# Grafana password
generate_secret_if_needed "gitlab-grafana-initial-password" --from-literal=password=$(gen_random 'a-zA-Z0-9' 64)
{{ end }}

{{ if .Values.global.praefect.enabled }}
# Praefect DB password
generate_secret_if_needed {{ template "gitlab.praefect.dbSecret.secret" . }} --from-literal={{ template "gitlab.praefect.dbSecret.key" . }}=$(gen_random 'a-zA-Z0-9', 32)

# Gitaly secret
generate_secret_if_needed {{ template "gitlab.praefect.authToken.secret" . }} --from-literal={{ template "gitlab.praefect.authToken.key" . }}=$(gen_random 'a-zA-Z0-9' 64)
{{ end }}
