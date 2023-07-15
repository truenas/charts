{{- define "logsearchapi.imageName" -}}
{{- printf "%s:%s" .Values.logSearchImage.repository .Values.logSearchImage.tag -}}
{{- end -}}

{{- define "logsearchapi.nameSuffix" -}}
{{- print "logsearchapi" -}}
{{- end -}}

{{- define "logsearchapi.command" -}}
{{- print "/logsearchapi" -}}
{{- end -}}

{{- define "logsearchapi.secretName" -}}
{{- print "logsearchapi-details" -}}
{{- end -}}

{{- define "logsearchapi.envVariableConfiguration" -}}
{{- $envList := list -}}
{{- $secretName := (include "logsearchapi.secretName" .) -}}
{{- $postgresSecretName := (include "postgres.secretName" .) -}}
{{- $envList = mustAppend $envList (dict "name" "MINIO_LOG_QUERY_AUTH_TOKEN" "valueFromSecret" true "secretName" $secretName "secretKey" "queryToken") -}}
{{- $envList = mustAppend $envList (dict "name" "LOGSEARCH_AUDIT_AUTH_TOKEN" "valueFromSecret" true "secretName" $secretName "secretKey" "auditToken") -}}
{{- $envList = mustAppend $envList (dict "name" "LOGSEARCH_PG_CONN_STR" "valueFromSecret" true "secretName" $postgresSecretName "secretKey" "postgresURL") -}}
{{- $envList = mustAppend $envList (dict "name" "LOGSEARCH_DISK_CAPACITY_GB" "value" .Values.logsearchapi.diskCapacityGB) -}}
{{- include "common.containers.environmentVariables" (dict "environmentVariables" $envList) -}}
{{- end -}}

{{/* Used in the minio init container (checks that logsearchapi is available) */}}
{{- define "logsearchapiInit.envVariableConfiguration" -}}
{{- $envList := list -}}
{{- $secretName := (include "logsearchapi.secretName" .) -}}
{{- $envList = mustAppend $envList (dict "name" "apiURL" "valueFromSecret" true "secretName" $secretName "secretKey" "logQueryURL") -}}
{{- include "common.containers.environmentVariables" (dict "environmentVariables" $envList) -}}
{{- end -}}
