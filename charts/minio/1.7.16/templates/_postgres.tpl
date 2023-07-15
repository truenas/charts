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

{{/*
Retrieve postgres backup name
This will return a unique name based on revision and chart numbers specified.
*/}}
{{- define "postgres.backupName" -}}
{{- $upgradeDict := .Values.ixChartContext.upgradeMetadata -}}
{{- printf "postgres-backup-from-%s-to-%s-revision-%d" $upgradeDict.oldChartVersion $upgradeDict.newChartVersion (int64 $upgradeDict.preUpgradeRevision) -}}
{{- end -}}

{{- define "postgres.envVariableConfiguration" -}}
{{- $envList := list -}}
{{- $secretName := (include "postgres.secretName" .) -}}
{{- $envList = mustAppend $envList (dict "name" "POSTGRES_USER" "valueFromSecret" true "secretName" $secretName "secretKey" "db_user") -}}
{{- $envList = mustAppend $envList (dict "name" "POSTGRES_DB" "valueFromSecret" true "secretName" $secretName "secretKey" "db_name") -}}
{{- $envList = mustAppend $envList (dict "name" "POSTGRES_PASSWORD" "valueFromSecret" true "secretName" $secretName "secretKey" "db_password") -}}
{{- include "common.containers.environmentVariables" (dict "environmentVariables" $envList) -}}
{{- end -}}

{{- define "postgresBackup.envVariableConfiguration" -}}
{{- $envList := list -}}
{{- $secretName := (include "postgres.secretName" .) -}}
{{- $envList = mustAppend $envList (dict "name" "POSTGRES_USER" "valueFromSecret" true "secretName" $secretName "secretKey" "db_user") -}}
{{- $envList = mustAppend $envList (dict "name" "POSTGRES_DB" "valueFromSecret" true "secretName" $secretName "secretKey" "db_name") -}}
{{/* PGPASSWORD is used by pg_dump */}}
{{- $envList = mustAppend $envList (dict "name" "PGPASSWORD" "valueFromSecret" true "secretName" $secretName "secretKey" "db_password") -}}
{{- $envList = mustAppend $envList (dict "name" "pgHost" "valueFromSecret" true "secretName" $secretName "secretKey" "postgresHost") -}}
{{- include "common.containers.environmentVariables" (dict "environmentVariables" $envList) -}}
{{- end -}}

{{/* Used in the logsearchapi init container (checks that postgres is available) */}}
{{- define "postgresInit.envVariableConfiguration" -}}
{{- $envList := list -}}
{{- $secretName := (include "postgres.secretName" .) -}}
{{- $envList = mustAppend $envList (dict "name" "pgHost" "valueFromSecret" true "secretName" $secretName "secretKey" "postgresHost") -}}
{{- $envList = mustAppend $envList (dict "name" "pguser" "valueFromSecret" true "secretName" $secretName "secretKey" "db_user") -}}
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
{{ include "common.storage.configureAppVolumeMountsInContainer" (dict "appVolumeMounts" .Values.postgresAppVolumeMounts ) | nindent 0 }}
{{- end -}}
