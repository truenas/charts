{{- define "nextcloud.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "nextcloud" -}}
  {{- $dbName := "nextcloud" -}}
  {{- $dbPass := (randAlphaNum 32) -}}

  {{/* Fetch secrets from pre-migration secret */}}
  {{- with (lookup "v1" "Secret" .Release.Namespace "db-details") -}}
    {{- $dbUser = ((index .data "db-user") | b64dec) -}}
    {{- if contains "\\x" (printf "%q" $dbUser) -}}
      {{- $dbUser = (index .data "db-user") -}}
    {{- end -}}
    {{- $dbPass = ((index .data "db-password") | b64dec) -}}
  {{- end -}}

  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbUser = ((index .data "POSTGRES_USER") | b64dec) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $redisHost := (printf "%s-redis" $fullname) -}}

  {{- $redisPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-redis-creds" $fullname)) -}}
    {{- $redisPass = ((index .data "REDIS_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "ncDbPass" $dbPass | quote -}}
  {{- $_ := set .Values "ncDbHost" $dbHost | quote -}}
  {{- $_ := set .Values "ncDbName" $dbName | quote -}}
  {{- $_ := set .Values "ncDbUser" $dbUser | quote -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

  redis-creds:
    enabled: true
    data:
      ALLOW_EMPTY_PASSWORD: "no"
      REDIS_PASSWORD: {{ $redisPass }}
      REDIS_HOST: {{ $redisHost }}

  nextcloud-creds:
    enabled: true
    data:
      POSTGRES_HOST: {{ $dbHost }}:5432
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      REDIS_HOST: {{ $redisHost }}
      REDIS_HOST_PORT: "6379"
      REDIS_HOST_PASSWORD: {{ $redisPass }}
      NEXTCLOUD_DATA_DIR: {{ .Values.ncConfig.dataDir }}
      PHP_UPLOAD_LIMIT: {{ printf "%vG" .Values.ncConfig.maxUploadLimit | default 3 }}
      PHP_MEMORY_LIMIT: {{ printf "%vM" .Values.ncConfig.phpMemoryLimit | default 512 }}
      {{- $host := "127.0.0.1" -}}
      {{- if .Values.ncConfig.host -}}
        {{- $host = printf "%v:%v" .Values.ncConfig.host .Values.ncNetwork.webPort -}}
        {{- if contains ":" $host  -}} {{/* Make sure it always contains a port https://ixsystems.atlassian.net/browse/TNCHARTS-1016 */}}
          {{- $host = .Values.ncConfig.host -}}
        {{- end -}}
      {{- end }}
      NEXTCLOUD_TRUSTED_DOMAINS: {{ list $host "127.0.0.1" "localhost" (printf "%v-*" $fullname) $fullname | mustUniq | join " " | quote }}
      NEXTCLOUD_ADMIN_USER: {{ .Values.ncConfig.adminUser | quote }}
      NEXTCLOUD_ADMIN_PASSWORD: {{ .Values.ncConfig.adminPassword | quote }}
    {{- if .Values.ncNetwork.certificateID }}
      {{- $svcCidr := "" -}}
      {{- $clusterCidr := "" -}}
      {{- if .Values.global.ixChartContext -}}
        {{- $svcCidr = .Values.global.ixChartContext.kubernetes_config.service_cidr -}}
        {{- $clusterCidr = .Values.global.ixChartContext.kubernetes_config.cluster_cidr -}}
      {{- end }}
      APACHE_DISABLE_REWRITE_IP: "1"
      OVERWRITEPROTOCOL: "https"
      TRUSTED_PROXIES: {{ list $svcCidr $clusterCidr "127.0.0.1" | mustUniq | join " " | quote }}
      {{- if .Values.ncConfig.host }}
        {{- $overwritehost := printf "%v:%v" .Values.ncConfig.host .Values.ncNetwork.webPort -}}
        {{- if .Values.ncNetwork.nginx.useDifferentAccessPort -}}
          {{ $overwritehost = printf "%v:%v" .Values.ncConfig.host .Values.ncNetwork.nginx.externalAccessPort -}}
          {{- if contains ":" .Values.ncConfig.host -}}
            {{- $overwritehost = .Values.ncConfig.host -}}
          {{- end -}}
        {{- end }}
      OVERWRITEHOST: {{ $overwritehost }}
      {{- end }}
    {{- end }}
  {{- if eq (include "nextcloud.is-migration" $) "true" }}
  postgres-backup-creds:
    enabled: true
    annotations:
      helm.sh/hook: "pre-upgrade"
      helm.sh/hook-delete-policy: "hook-succeeded"
      helm.sh/hook-weight: "1"
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName }}
  {{- end }}
{{- end -}}
