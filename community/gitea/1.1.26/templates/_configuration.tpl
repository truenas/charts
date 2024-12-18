{{- define "gitea.configuration" -}}

  {{ if not (hasPrefix "http" .Values.giteaNetwork.rootURL) }}
    {{ fail "Gitea - Expected [Root URL] to have the following format [http(s)://(sub).domain.tld(:port)] or [http://IP_ADDRESS:port]" }}
  {{ end }}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "gitea" -}}
  {{- $dbName := "gitea" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "giteaDbPass" $dbPass -}}
  {{- $_ := set .Values "giteaDbHost" $dbHost -}}

  {{ $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

  gitea-creds:
    enabled: true
    data:
      GITEA__database__DB_TYPE: postgres
      GITEA__database__PASSWD: {{ $dbPass }}
      GITEA__database__HOST: {{ $dbHost }}
      GITEA__database__NAME: {{ $dbName }}
      GITEA__database__USER: {{ $dbUser }}
configmap:
  gitea-config:
    enabled: true
    data:
      {{ $protocol := "http" }}
      GITEA__server__HTTP_PORT: {{ .Values.giteaNetwork.webPort | quote }}
      GITEA__server__SSH_PORT: {{ .Values.giteaNetwork.externalSshPort | default .Values.giteaNetwork.sshPort | quote }}
      GITEA__server__SSH_LISTEN_PORT: {{ .Values.giteaNetwork.sshPort | quote }}
      GITEA__server__ROOT_URL: {{ .Values.giteaNetwork.rootURL | quote }}
      {{ if .Values.giteaNetwork.certificateID }}
      {{ $protocol = "https" }}
      GITEA__server__CERT_FILE: /etc/certs/gitea/public.crt
      GITEA__server__KEY_FILE: /etc/certs/gitea/private.key
      {{ end }}
      GITEA__server__PROTOCOL: {{ $protocol }}

{{ with .Values.giteaNetwork.certificateID }}
scaleCertificate:
  gitea-cert:
    enabled: true
    id: {{ . }}
{{ end }}

{{- end -}}
