{{- define "passbolt.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-mariadb" $fullname) -}}
  {{- $dbUser := "passbolt" -}}
  {{- $dbName := "passbolt" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- $dbRootPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-mariadb-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "MARIADB_PASSWORD") | b64dec) -}}
    {{- $dbRootPass = ((index .data "MARIADB_ROOT_PASSWORD") | b64dec) -}}
  {{- end }}

secret:
  mariadb-creds:
    enabled: true
    data:
      MARIADB_USER: {{ $dbUser }}
      MARIADB_DATABASE: {{ $dbName }}
      MARIADB_PASSWORD: {{ $dbPass }}
      MARIADB_ROOT_PASSWORD: {{ $dbRootPass }}
      MARIADB_HOST: {{ $dbHost }}

  passbolt-creds:
    enabled: true
    data:
      DATASOURCES_DEFAULT_HOST: {{ $dbHost }}
      DATASOURCES_DEFAULT_DATABASE: {{ $dbName }}
      DATASOURCES_DEFAULT_USERNAME: {{ $dbUser }}
      DATASOURCES_DEFAULT_PASSWORD: {{ $dbPass }}
      DATASOURCES_DEFAULT_PORT: "3306"

configmap:
  passbolt-config:
    enabled: true
    data:
      APP_FULL_BASE_URL: {{ .Values.passboltConfig.appUrl }}
      GNUPGHOME: /var/lib/passbolt/.gnupg
      PASSBOLT_GPG_SERVER_KEY_PUBLIC: /etc/passbolt/gpg/serverkey.asc
      PASSBOLT_GPG_SERVER_KEY_PRIVATE: /etc/passbolt/gpg/serverkey_private.asc
{{- end -}}
