{{/*
Render environment variables
*/}}
{{- define "common.containers.environmentVariables" -}}
{{- $values := . -}}
{{- include "common.schema.validateKeys" (dict "values" $values "checkKeys" (list "environmentVariables")) -}}
{{- range $envVariable := $values.environmentVariables -}}
{{- include "common.containers.environmentVariable" $envVariable | nindent 0 -}}
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
Render environment variable
*/}}
{{- define "common.containers.environmentVariable" -}}
{{- $envVariable := . -}}
{{- include "common.schema.validateKeys" (dict "values" $envVariable "checkKeys" (list "name")) -}}
{{- if $envVariable.valueFromSecret -}}
{{- include "common.schema.validateKeys" (dict "values" $envVariable "checkKeys" (list "secretName" "secretKey")) -}}
- name: {{ $envVariable.name | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ $envVariable.secretName | quote }}
      key: {{ $envVariable.secretKey | quote }}
{{- else -}}
{{- include "common.schema.validateKeys" (dict "values" $envVariable "checkKeys" (list "value")) -}}
- name: {{ $envVariable.name | quote }}
  value: {{ $envVariable.value | quote }}
{{- end -}}
{{- end -}}

{{/*
Retrieve deployment pod's metadata
*/}}
{{- define "common.deployment.pod.metadata" -}}
metadata:
  name: {{ template "common.names.fullname" . }}
  labels: {{ include "common.labels.selectorLabels" . | nindent 4 }}
  annotations: {{ include "common.annotations" . | nindent 4 }}
{{- end -}}

{{/*
Retrieve replicas/strategy/selector
*/}}
{{- define "common.deployment.common_spec" -}}
replicas: {{ (default 1 .Values.replicas) }}
strategy:
  type: {{ (default "Recreate" .Values.updateStrategy ) }}
selector:
  matchLabels: {{ include "common.labels.selectorLabels" . | nindent 4 }}
{{- end -}}

{{/*
Retrieve common deployment configuration
*/}}
{{- define "common.deployment.common_config" -}}
apiVersion: {{ template "common.capabilities.deployment.apiVersion" . }}
kind: Deployment
{{ include "common.deployment.metadata" . | nindent 0 }}
{{- end -}}

{{/*
Retrieve deployment metadata
*/}}
{{- define "common.deployment.metadata" -}}
metadata:
  name: {{ template "common.names.fullname" . }}
  labels: {{ include "common.labels.selectorLabels" . | nindent 4 }}
{{- end -}}




{{/*
Render environment variables
*/}}
{{- define "common.containers.environmentVariables" -}}
{{- $values := . -}}
{{- include "common.schema.validateKeys" (dict "values" $values "checkKeys" (list "environmentVariables")) -}}
{{- range $envVariable := $values.environmentVariables -}}
{{- include "common.containers.environmentVariable" $envVariable | nindent 0 -}}
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
Render environment variable
*/}}
{{- define "common.containers.environmentVariable" -}}
{{- $envVariable := . -}}
{{- include "common.schema.validateKeys" (dict "values" $envVariable "checkKeys" (list "name")) -}}
{{- if $envVariable.valueFromSecret -}}
{{- include "common.schema.validateKeys" (dict "values" $envVariable "checkKeys" (list "secretName" "secretKey")) -}}
- name: {{ $envVariable.name | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ $envVariable.secretName | quote }}
      key: {{ $envVariable.secretKey | quote }}
{{- else -}}
{{- include "common.schema.validateKeys" (dict "values" $envVariable "checkKeys" (list "value")) -}}
- name: {{ $envVariable.name | quote }}
  value: {{ $envVariable.value | quote }}
{{- end -}}
{{- end -}}

{{/*
Retrieve deployment pod's metadata
*/}}
{{- define "common.deployment.pod.metadata" -}}
metadata:
  name: {{ template "common.names.fullname" . }}
  labels: {{ include "common.labels.selectorLabels" . | nindent 4 }}
  annotations: {{ include "common.annotations" . | nindent 4 }}
{{- end -}}

{{/*
Retrieve replicas/strategy/selector
*/}}
{{- define "common.deployment.common_spec" -}}
replicas: {{ (default 1 .Values.replicas) }}
strategy:
  type: {{ (default "Recreate" .Values.updateStrategy ) }}
selector:
  matchLabels: {{ include "common.labels.selectorLabels" . | nindent 4 }}
{{- end -}}

{{/*
Retrieve common deployment configuration
*/}}
{{- define "common.deployment.common_config" -}}
apiVersion: {{ template "common.capabilities.deployment.apiVersion" . }}
kind: Deployment
{{ include "common.deployment.metadata" . | nindent 0 }}
{{- end -}}

{{/*
Retrieve deployment metadata
*/}}
{{- define "common.deployment.metadata" -}}
metadata:
  name: {{ template "common.names.fullname" . }}
  labels: {{ include "common.labels.selectorLabels" . | nindent 4 }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.names.fullname" -}}
{{- $values := (.common | default dict) -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- $name = (.Release.Name | trunc 63 | trimSuffix "-") }}
{{- else }}
{{- $name = (printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-") }}
{{- end }}
{{- if hasKey $values "nameSuffix" -}}
  {{- $name = (printf "%v-%v" $name $values.nameSuffix) -}}
{{ end -}}
{{- print $name -}}
{{- end }}
{{- end }}

{{/*
Selector labels shared across objects.
*/}}
{{- define "common.labels.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ include "common.names.releaseName" . }}
{{ if hasKey .Values "extraSelectorLabels" }}
{{ range $selector := .Values.extraSelectorLabels }}
{{ printf "%s: %s" $selector.key $selector.value }}
{{ end }}
{{ end }}
{{- end }}


{{/*
Expand the name of the chart.
*/}}
{{- define "common.names.name" -}}
{{- $values := (.common | default dict) -}}
{{- $name := (default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-") }}
{{- if hasKey $values "nameSuffix" -}}
  {{- $name = (printf "%v-%v" $name $values.nameSuffix) -}}
{{ end -}}
{{- print $name -}}
{{- end }}

{{/*
Determine release name
This will add a suffix to the release name if nameSuffix is set
*/}}
{{- define "common.names.releaseName" -}}
{{- $values := (.common | default dict) -}}
{{- if hasKey $values "nameSuffix" -}}
  {{- printf "%v-%v" .Release.Name $values.nameSuffix -}}
{{- else -}}
  {{- print .Release.Name -}}
{{ end -}}
{{- end -}}
