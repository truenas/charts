{{- define "postgres.imageName" -}}
{{- print "postgres:14.5" -}}
{{- end -}}

{{- define "postgres.nameSuffix" -}}
{{- print "postgres" -}}
{{- end -}}

{{- define "postgres.secretName" -}}
{{- print "postgres-details" -}}
{{- end -}}

{{- define "postgres.dbName" -}}
{{- print "logsearchapi" -}}
{{- end -}}

{{- define "postgres.dbUser" -}}
{{- print "logsearchapi" -}}
{{- end -}}

{{- define "postgres.envVariableConfiguration" -}}
{{- $envList := list -}}
{{- $secretName := (include "postgres.secretName" .) -}}
{{- $envList = mustAppend $envList (dict "name" "POSTGRES_USER" "valueFromSecret" true "secretName" $secretName "secretKey" "db_user") -}}
{{- $envList = mustAppend $envList (dict "name" "POSTGRES_DB" "valueFromSecret" true "secretName" $secretName "secretKey" "db_name") -}}
{{- $envList = mustAppend $envList (dict "name" "POSTGRES_PASSWORD" "valueFromSecret" true "secretName" $secretName "secretKey" "db_password") -}}
{{- include "common.containers.environmentVariables" (dict "environmentVariables" $envList) -}}
{{- end -}}

{{/*
Retrieve postgres volume configuration
*/}}
{{- define "postgres.volumeConfiguration" -}}
{{ include "common.storage.configureAppVolumes" (dict "appVolumeMounts" .Values.postgresAppVolumeMounts "emptyDirVolumes" .Values.emptyDirVolumes "ixVolumes" .Values.ixVolumes) | nindent 0 }}
{{- end -}}

{{/*
Retrieve postgres volume mounts configuration
*/}}
{{- define "postgres.volumeMountsConfiguration" -}}
{{ include "common.storage.configureAppVolumeMountsInContainer" (dict "appVolumeMounts" .Values.postgresql ) | nindent 0 }}
{{- end -}}
