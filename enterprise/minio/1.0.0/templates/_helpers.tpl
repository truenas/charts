{{- define "minio.scheme" -}}
  {{- $scheme := "http" -}}
  {{- if .Values.minio.network.certificate_id -}}
    {{- $scheme = "https" -}}
  {{- end -}}

  {{- $scheme -}}
{{- end -}}

{{- define "minio.validation" -}}
  {{- if not .Values.minio.creds.root_user -}}
    {{- fail "Expected non-empty <root_user>" -}}
  {{- end -}}

  {{- if not .Values.minio.creds.root_pass -}}
    {{- fail "Expected non-empty <root_pass>" -}}
  {{- end -}}

  {{- if not .Values.minio.storage -}}
    {{- fail "Expected at least 1 storage item added" -}}
  {{- end -}}

  {{- if and (ne (len .Values.minio.storage) 1) (not .Values.minio.multi_mode) -}}
    {{- fail "Expected Multi Mode to be enabled, when more than 1 storage items added" -}}
  {{- end -}}
{{- end -}}

{{- define "minio.permissions" -}}
  {{- $type := .type -}}
  {{- $UID := .UID -}}
  {{- $GID := .GID }}
permissions:
  enabled: true
  type: {{ $type | default "install" }}
  imageSelector: bashImage
  resources:
    limits:
      cpu: 1000m
      memory: 512Mi
  securityContext:
    runAsUser: 0
    runAsGroup: 0
    runAsNonRoot: false
    readOnlyRootFilesystem: false
    capabilities:
      add:
        - CHOWN
  command: bash
  args:
    - -c
    - |
      echo "Changing ownership to {{ $UID }}:{{ $GID }} on the following directories:"
      ls -la /mnt/directories
      chown -R {{ $UID }}:{{ $GID }} /mnt/directories
      echo "Finished changing ownership"
      echo "Permissions after changing ownership:"
      ls -la /mnt/directories
{{- end -}}

{{- define "minio.prepare.config" -}}
  {{/* Prepare logsearch related config, shared across different configmaps */}}
  {{- $config := dict -}}
  {{- if .Values.logsearch.enabled -}}
    {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
    {{- $_ := set $config "dbHost" (printf "%s-postgres" $fullname ) -}}

    {{- $_ := set $config "dbPass" (randAlphaNum 32) -}}
    {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
      {{- $_ := set $config "dbPass" ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
    {{- end -}}

    {{- $_ := set $config "auditToken" (randAlphaNum 32) -}}
    {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-logsearch-creds" $fullname)) -}}
      {{- $_ := set $config "auditToken" ((index .data "LOGSEARCH_AUDIT_AUTH_TOKEN") | b64dec) -}}
    {{- end -}}

    {{- $_ := set $config "queryToken" (randAlphaNum 32) -}}
    {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-logsearch-creds" $fullname)) -}}
      {{- $_ := set $config "queryToken" ((index .data "MINIO_LOG_QUERY_AUTH_TOKEN") | b64dec) -}}
    {{- end -}}
    {{- $_ := set $config "diskCapacity" (required "Expected non-empty <disk_capacity_gb>" .Values.logsearch.disk_capacity_gb) -}}

    {{- $_ := set $config "dbUser" "logsearch" -}}
    {{- $_ := set $config "dbName" "logsearch" -}}
    {{- $_ := set $config "logQueryURL" (printf "http://%s-logsearch:8080" $fullname) -}}
    {{- $_ := set $config "webhookURL" (printf "%s/api/ingest?token=%v" $config.logQueryURL $config.auditToken) -}}
    {{- $_ := set $config "postgresURL" (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $config.dbUser $config.dbPass $config.dbHost $config.dbName) -}}
  {{- end -}}

  {{- if .Values.minio.multi_mode -}} {{/* Maybe validate againist a regex each entry? */}}
    {{- $_ := set $config "volumes" (join " " .Values.minio.multi_mode) -}}
  {{- else -}}  {{/* When no multi mode, use the first storage entry */}}
    {{- $_ := set $config "volumes" (.Values.minio.storage | first).mountPath -}}
  {{- end -}}

  {{- if not $config.volumes -}}
    {{- fail "ERROR: Volumes can't be empty" -}}
  {{- end -}}

  {{- $config | toJson -}}
{{- end -}}
