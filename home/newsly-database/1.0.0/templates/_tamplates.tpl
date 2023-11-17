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
