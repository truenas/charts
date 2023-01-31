{{- define "ix.v1.common.lib.pod.restartPolicy" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{/* Initialize from the "defaults" */}}
  {{- $policy := $rootCtx.Values.podOptions.restartPolicy -}}

  {{/* Override from the pod values, if defined */}}
  {{- with $objectData.podSpec.restartPolicy -}}
    {{- $policy = . -}}
  {{- end -}}

  {{- if not (mustHas $policy (list "Always" "Never" "OnFailure")) -}}
    {{- fail (printf "Expected <restartPolicy to be one of [Never, Always, OnFailure] but got [%s]" $policy) -}}
  {{- end -}}

  {{- if and (ne "Always" $policy) (mustHas $objectData.type (list "Deployment" "DaemonSet" "StatefulSet")) -}}
    {{- fail (printf "Expected <restartPolicy to be [Always] for [%s] but got [%s]" $objectData.type $policy) -}}
  {{- end -}}

  {{- $policy -}}
{{- end -}}
