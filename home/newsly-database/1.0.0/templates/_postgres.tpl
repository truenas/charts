{{/*
Get Home assistance Postgres Database Name
*/}}
{{- define "postgres.DatabaseName" -}}
{{- print "homeassistance" -}}
{{- end -}}


{{- define "postgres.imageName" -}}
{{- print "registry.departy.xyz/newsly-database:2023.11.17" -}}
{{- end -}}


{{/*
Retrieve postgres backup name
This will return a unique name based on revision and chart numbers specified.
*/}}
{{- define "postgres.backupName" -}}
{{- $upgradeDict := .Values.ixChartContext.upgradeMetadata -}}
{{- printf "postgres-backup-from-%s-to-%s-revision-%d" $upgradeDict.oldChartVersion $upgradeDict.newChartVersion (int64 $upgradeDict.preUpgradeRevision) -}}
{{- end }}


{{/*
Retrieve postgres credentials for environment variables configuration
*/}}
{{- define "postgres.envVariableConfiguration" -}}
{{ $envList := list }}
{{ $envList = mustAppend $envList (dict "name" "POSTGRES_USER" "valueFromSecret" true "secretName" "db-details" "secretKey" "db-user") }}
{{ $envList = mustAppend $envList (dict "name" "POSTGRES_PASSWORD" "valueFromSecret" true "secretName" "db-details" "secretKey" "db-password") }}
{{ include "common.containers.environmentVariables" (dict "environmentVariables" $envList) }}
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



{{/*
Define hostPath for appVolumes
*/}}
{{- define "common.storage.configureAppVolumes" -}}
{{- include "common.schema.validateKeys" (dict "values" . "checkKeys" (list "appVolumeMounts")) -}}
{{- $values := . -}}
{{- if $values.appVolumeMounts -}}
{{- range $name, $av := $values.appVolumeMounts -}}
{{ if (default true $av.enabled) }}
- name: {{ $name }}
  {{ if or $av.emptyDir $.emptyDirVolumes }}
  emptyDir: {}
  {{- else -}}
  hostPath:
    {{ if $av.hostPathEnabled }}
    path: {{ required "hostPath not set" $av.hostPath }}
    {{ else }}
    {{- include "common.schema.validateKeys" (dict "values" $values "checkKeys" (list "ixVolumes")) -}}
    {{- include "common.schema.validateKeys" (dict "values" $av "checkKeys" (list "datasetName")) -}}
    {{- $volDict := dict "datasetName" $av.datasetName "ixVolumes" $values.ixVolumes -}}
    path: {{ include "common.storage.retrieveHostPathFromiXVolume" $volDict }}
    {{ end }}
  {{ end }}
{{ end }}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Validates the keys in a dictionary.
*/}}
{{- define "common.schema.validateKeys" -}}
{{- $values := . -}}
{{- if and (hasKey $values "values") (hasKey $values "checkKeys") -}}
{{- $missingKeys := list -}}
{{- range $values.checkKeys -}}
{{- if eq (hasKey $values.values . ) false -}}
{{- $missingKeys = mustAppend $missingKeys . -}}
{{- end -}}
{{- end -}}
{{- if $missingKeys -}}
{{- fail (printf "Missing %s from dictionary" ($missingKeys | join ", ")) -}}
{{- end -}}
{{- else -}}
{{- fail "A dictionary and list of keys to check must be provided" -}}
{{- end -}}
{{- end -}}

{{/*
Configures application volume mounts in a container.
*/}}
{{- define "common.storage.configureAppVolumeMountsInContainer" -}}
{{- include "common.schema.validateKeys" (dict "values" . "checkKeys" (list "appVolumeMounts")) -}}
{{- $appVolumeMounts := .appVolumeMounts -}}
{{- if $appVolumeMounts -}}
{{ range $name, $avm := $appVolumeMounts }}
{{- if (default true $avm.enabled) -}}
{{ if $avm.containerNameOverride }}
{{ $name = $avm.containerNameOverride }}
{{ end }}
- name: {{ $name }}
  mountPath: {{ $avm.mountPath }}
  {{ if $avm.subPath }}
  subPath: {{ $avm.subPath }}
  {{ end }}
  {{ if $avm.readOnly }}
  readOnly: {{ $avm.readOnly }}
  {{ end }}
{{- end -}}
{{ end }}
{{- end -}}
{{- end -}}

