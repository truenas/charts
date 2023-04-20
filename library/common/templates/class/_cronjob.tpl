{{/* CronJob Class */}}
{{/* Call this template:
{{ include "ix.v1.common.class.cronjob" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData: The object data to be used to render the CronJob.
*/}}

{{- define "ix.v1.common.class.cronjob" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- include "ix.v1.common.lib.workload.cronjobValidation" (dict "objectData" $objectData) }}
---
apiVersion: batch/v1
kind: CronJob
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
  {{- include "ix.v1.common.lib.workload.cronjobSpec" (dict "rootCtx" $rootCtx "objectData" $objectData) | nindent 2 }}
      template:
        metadata:
            {{- $labels := (mustMerge ($objectData.podSpec.labels | default dict)
                                      (include "ix.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)
                                      (include "ix.v1.common.lib.metadata.podLabels" $rootCtx | fromYaml)
                                      (include "ix.v1.common.lib.metadata.selectorLabels" (dict "rootCtx" $rootCtx "objectType" "pod" "objectName" $objectData.shortName) | fromYaml)) -}}
            {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
          labels:
            {{- . | nindent 12 }}
            {{- end -}}
            {{- $annotations := (mustMerge ($objectData.podSpec.annotations | default dict)
                                            (include "ix.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)
                                            (include "ix.v1.common.lib.metadata.externalInterfacePodAnnotations" (dict "rootCtx" $rootCtx "objectData" $objectData) | fromYaml)
                                            (include "ix.v1.common.lib.metadata.podAnnotations" $rootCtx | fromYaml)) -}}
            {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
          annotations:
            {{- . | nindent 12 }}
            {{- end }}
        spec:
          {{- include "ix.v1.common.lib.workload.pod" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 10 }}
{{- end -}}
