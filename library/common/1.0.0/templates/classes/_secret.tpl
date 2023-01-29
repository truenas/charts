{{/* Secret Class */}}
{{/* Call this template:
{{ include "ix.v1.common.class.secret" (dict "objectData" $objectData "rootCtx" $) }}

rootCtx: The root context of the template. It is used to access the global context.
objectData:
  name: The name of the secret.
  labels: The labels of the secret.
  annotations: The annotations of the secret.
  type: The type of the secret.
  data: The data of the secret.
*/}}

{{- define "ix.v1.common.class.secret" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- $secretType := "Opaque" -}}

  {{- if eq $objectData.type "certificate" -}}
    {{- $secretType = "kubernetes.io/tls" -}}
  {{- else if eq $objectData.type "imagePullSecret" -}}
    {{- $secretType = "kubernetes.io/dockerconfigjson" -}}
  {{- else if $objectData.type -}}
    {{- $secretType = $objectData.type -}}
  {{- end }}
---
apiVersion: v1
kind: Secret
type: {{ $secretType }}
metadata:
  name: {{ $objectData.name }}
  {{- $labels := (mustMerge ($objectData.labels | default dict) (include "ix.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($objectData.annotations | default dict) (include "ix.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- if (mustHas $objectData.type (list "certificate" "imagePullSecret")) }}
data:
    {{- if eq $objectData.type "certificate" }}
      {{/* TODO: print certificate values and test */}}
    {{- else if eq $objectData.type "imagePullSecret" }}
  .dockerconfigjson: {{ $objectData.data | trim | b64enc }}
    {{- end -}}
  {{- else }}
stringData:
    {{- tpl (toYaml $objectData.data) $rootCtx | nindent 2 }}
    {{/* This comment is here to add a new line */}}
  {{- end -}}
{{- end -}}
