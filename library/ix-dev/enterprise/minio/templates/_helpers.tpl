{{/* Scheme */}}
{{- define "minio.scheme" -}}
  {{- $scheme := "http" -}}
  {{- if .Values.minioNetwork.certificateID -}}
    {{- $scheme = "https" -}}
  {{- end -}}

  {{- $scheme -}}
{{- end -}}

{{- define "minio.hostnetwork" -}}
  {{- $hostNet := .Values.minioNetwork.hostNetwork -}}

  {{- range $entry := .Values.minioMultiMode -}}
    {{/*
      Only if multi mode has urls set hostnetwork,
      Multi Mode can be used for single node, multi disk setup
     */}}
    {{- if contains "://" $entry -}}
      {{- $hostNet = true -}}
    {{- end -}}

  {{- end -}}
  {{- $hostNet -}}
{{- end -}}

{{/* Validation */}}
{{- define "minio.validation" -}}
  {{- if not .Values.minioCreds.rootUser -}}
    {{- fail "Expected non-empty <rootUser>" -}}
  {{- end -}}

  {{- if not .Values.minioCreds.rootPass -}}
    {{- fail "Expected non-empty <rootPass>" -}}
  {{- end -}}

  {{- if not .Values.minioStorage -}}
    {{- fail "Expected at least 1 storage item added" -}}
  {{- end -}}

  {{- if and (ne (len .Values.minioStorage) 1) (not .Values.minioMultiMode) -}}
    {{- fail "Expected Multi Mode to be enabled, when more than 1 storage mountPaths added" -}}
  {{- end -}}

  {{- $notAllowedKeys := (list "server") -}} {{/* Extend if needed */}}
  {{- range $item := .Values.minioMultiMode -}}
    {{- if (mustHas $item $notAllowedKeys) -}}
      {{- fail (printf "Key [%v] is not allowed as a Multi Mode argument" $item) -}}
    {{- end -}}

    {{- if hasPrefix "/" $item -}}
      {{- if or (contains "{" $item) (contains "}" $item) -}}
        {{- if not (contains "..." $item) -}}
          {{- fail "Expected Multi Mode Item to have 3 dots when its a path with expansion eg [/some_path{1...4}]" -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $mountPaths := list -}}
  {{- range $item := .Values.minioStorage -}}
    {{- $mountPaths = mustAppend $mountPaths $item.mountPath -}}
  {{- end -}}

  {{- if not (deepEqual ($mountPaths) (uniq $mountPaths)) -}}
    {{- fail (printf "Expected mountPaths to be unique, but got [%v]" (join ", " $mountPaths)) -}}
  {{- end -}}
{{- end -}}

{{/* Config preparation */}}
{{- define "minio.prepare.config" -}}
  {{/* Prepare logsearch related config, shared across different configmaps */}}
  {{- $config := dict -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- if .Values.minioLogging.logsearch.enabled -}}
    {{- $_ := set $config "diskCapacity" (required "Expected non-empty <disk_capacity_gb>" .Values.minioLogging.logsearch.diskCapacityGB) -}}
  {{- end -}}

  {{- $_ := set $config "dbUser" "logsearch" -}}
  {{- $_ := set $config "dbName" "logsearch" -}}

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

  {{- $_ := set $config "dbHost" (printf "%s-postgres" $fullname ) -}}
  {{- $_ := set $config "logQueryURL" (printf "http://%s-logsearch:8080" $fullname) -}}
  {{- $_ := set $config "webhookURL" (printf "%s/api/ingest?token=%v" $config.logQueryURL $config.auditToken) -}}
  {{- $_ := set $config "postgresURL" (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $config.dbUser $config.dbPass $config.dbHost $config.dbName) -}}

  {{/* When no multi mode, use the first storage entry */}}
  {{- $_ := set $config "volumes" (.Values.minioStorage | first).mountPath -}}
  {{- if .Values.minioMultiMode -}}
    {{- $_ := set $config "volumes" (join " " .Values.minioMultiMode) -}}
  {{- end -}}

  {{- if not $config.volumes -}}
    {{- fail "ERROR: Volumes can't be empty" -}}
  {{- end -}}

  {{- $config | toJson -}}
{{- end -}}
