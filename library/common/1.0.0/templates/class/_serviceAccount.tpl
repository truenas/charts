{{/* Service Account Class */}}
{{/* Call this template:
{{ include "ix.v1.common.class.serviceAccount" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the template. It is used to access the global context.
objectData:
  name: The name of the serviceAccount.
  labels: The labels of the serviceAccount.
  annotations: The annotations of the serviceAccount.
  autoMountToken: Whether to mount the ServiceAccount token or not.
*/}}

{{- define "ix.v1.common.class.serviceAccount" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
---
apiVersion: v1
kind: ServiceAccount
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
{{- end -}}
