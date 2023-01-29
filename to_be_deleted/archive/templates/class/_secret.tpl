{{/*
Call this template like this;
{{- include "ix.v1.common.class.configmap" (dict "root" $root "values" $values) -}}
$values contains:
  name: string
  contentType: yaml | certificate | pullSecret
  data: dict or (data | toYaml) when contentType is yaml
  secretType: custom secret type # Optional
  labels: dict # Optional
  annotations: dict # Optional
*/}}
{{- define "ix.v1.common.class.secret" -}}
  {{- $values := .values -}}
  {{- $root := .root -}}

  {{- $typeClass := "Opaque" -}} {{/* Default to Opaque */}}
  {{- if eq $values.contentType "certificate" -}} {{/* Certificate content has specific type */}}
    {{- $typeClass = (include "ix.v1.common.capabilities.secret.certificate.type" $root) -}}
  {{- else if eq $values.contentType "pullSecret" -}} {{/* imagePullSecrets content has specific type */}}
    {{- $typeClass = (include "ix.v1.common.capabilities.secret.imagePullSecret.type" $root) -}}
  {{- end -}}

  {{- if $values.secretType -}} {{/* If custom type is defined */}}
    {{- $typeClass = $values.secretType -}}
  {{- end }}
---
apiVersion: {{ include "ix.v1.common.capabilities.secret.apiVersion" $root }}
kind: Secret
type: {{ $typeClass }}
metadata:
  name: {{ $values.name }}
  {{- $labels := (mustMerge ($values.labels | default dict) (include "ix.v1.common.labels" $root | fromYaml)) -}}
  {{- with (include "ix.v1.common.util.labels.render" (dict "root" $root "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($values.annotations | default dict) (include "ix.v1.common.annotations" $root | fromYaml)) -}}
  {{- with (include "ix.v1.common.util.annotations.render" (dict "root" $root "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- if (mustHas $values.contentType (list "pullSecret" "certificate")) }}
data:
  {{- if eq $values.contentType "pullSecret" }}
  .dockerconfigjson: {{ $values.data | toJson | b64enc }}
    {{- else if eq $values.contentType "certificate" }}
      {{- range $k, $v := $values.data }}
        {{- $k | nindent 2 }}: {{ $v | b64enc }}
      {{- end -}}
    {{- end -}}
  {{- else if eq $values.contentType "yaml" }}
stringData:
    {{- $values.data | nindent 2 }}
  {{- else -}}
    {{- fail (printf "Invalid content type (%s) for secret. Valid types are pullSecret, certificate, yaml" $values.contentType) -}}
  {{- end -}}
{{- end -}}
