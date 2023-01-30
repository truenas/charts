{{/* StatefulSet Class */}}
{{/* Call this template:
{{ include "ix.v1.common.class.deployment" (dict "objectData" $objectData "rootCtx" $) }}

rootCtx: The root context of the template. It is used to access the global context.
objectData:
  name: The name of the statefulset.
  labels: The labels of the statefulset.
  annotations: The annotations of the statefulset.
  replicas: The number of replicas.
  revisionHistoryLimit: The number of old ReplicaSets to retain to allow rollback.
  strategy: The deployment strategy.
*/}}

{{- define "ix.v1.common.class.statefulset" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- include "ix.v1.common.lib.controller.statefulsetValidation" (dict "objectData" $objectData) }}
---
apiVersion: apps/v1
kind: StatefulSet
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
  {{- end }}
spec:
  {{- include "ix.v1.common.lib.controller.statefulsetSpec" (dict "rootCtx" $rootCtx "objectData" $objectData) | nindent 2 }}

{{- end -}}
