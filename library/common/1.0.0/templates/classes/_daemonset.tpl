{{/* DaemonSet Class */}}
{{/* Call this template:
{{ include "ix.v1.common.class.deployment" (dict "objectData" $objectData "rootCtx" $) }}

rootCtx: The root context of the template. It is used to access the global context.
objectData:
  name: The name of the daemonset.
  labels: The labels of the daemonset.
  annotations: The annotations of the daemonset.
  replicas: The number of replicas.
  revisionHistoryLimit: The number of old ReplicaSets to retain to allow rollback.
  strategy: The deployment strategy.
*/}}

{{- define "ix.v1.common.class.daemonset" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- include "ix.v1.common.lib.controller.daemonsetValidation" (dict "objectData" $objectData) }}
---
apiVersion: apps/v1
kind: DaemonSet
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
  {{- include "ix.v1.common.lib.controller.daemonsetSpec" (dict "rootCtx" $rootCtx "objectData" $objectData) | nindent 2 }}

{{- end -}}
