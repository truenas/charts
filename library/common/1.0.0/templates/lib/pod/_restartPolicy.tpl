{{/* Returns Restart Policy */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.restartPolicy" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the template. It is used to access the global context.
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

  {{- if not (mustHas $policy (list "Always" "Never" "OnFailure")) -}}
    {{- fail (printf "Expected <restartPolicy to be one of [Never, Always, OnFailure] but got [%s]" $policy) -}}
  {{- end -}}

  {{- if and (ne "Always" $policy) (mustHas $objectData.type (list "Deployment" "DaemonSet" "StatefulSet")) -}}
    {{- fail (printf "Expected <restartPolicy to be [Always] for [%s] but got [%s]" $objectData.type $policy) -}}
  {{- end -}}

  {{- $policy -}}
{{- end -}}
