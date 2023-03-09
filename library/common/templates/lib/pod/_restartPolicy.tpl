{{/* Returns Restart Policy */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.restartPolicy" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.restartPolicy" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $policy := "Always" -}}

  {{/* Initialize from the "defaults" */}}
  {{- with $rootCtx.Values.podOptions.restartPolicy -}}
    {{- $policy = tpl . $rootCtx -}}
  {{- end -}}

  {{/* Override from the pod values, if defined */}}
  {{- with $objectData.podSpec.restartPolicy -}}
    {{- $policy = tpl . $rootCtx -}}
  {{- end -}}

  {{- $policies := (list "Never" "Always" "OnFailure") -}}
  {{- if not (mustHas $policy $policies) -}}
    {{- fail (printf "Expected <restartPolicy to be one of [%s] but got [%s]" (join ", " $policies) $policy) -}}
  {{- end -}}

  {{- $types := (list "Deployment") -}}
  {{- if and (ne "Always" $policy) (mustHas $objectData.type $types) -}}
    {{- fail (printf "Expected <restartPolicy to be [Always] for [%s] but got [%s]" $objectData.type $policy) -}}
  {{- end -}}

  {{- $types := (list "Job" "CronJob") -}}
  {{- if and (eq "Always" $policy) (mustHas $objectData.type $types) -}}
    {{- fail (printf "Expected <restartPolicy to be [OnFailure, Never] for [%s] but got [%s]" $objectData.type $policy) -}}
  {{- end -}}

  {{- $policy -}}
{{- end -}}
