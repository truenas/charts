{{/* Workload Basic Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.workload.primaryValidation" $ -}}
*/}}
{{- define "ix.v1.common.lib.workload.primaryValidation" -}}

  {{/* Initialize values */}}
  {{- $hasPrimary := false -}}
  {{- $hasEnabled := false -}}

  {{/* Go over workload */}}
  {{- range $name, $workload := .Values.workload -}}

    {{- if not (mustHas $workload.type (list "Deployment" "StatefulSet" "DaemonSet" "Job" "CronJob")) -}}
      {{- fail (printf "Workload - Expected <type> to be one of [Deployment, StatefulSet, DaemonSet, Job, CronJob], but got [%s]" $workload.type) -}}
    {{- end -}}

    {{/* If workload is enabled */}}
    {{- if $workload.enabled -}}
      {{- $hasEnabled = true -}}

      {{/* And workload is primary */}}
      {{- if and (hasKey $workload "primary") ($workload.primary) -}}

        {{/* Fail if there is already a primary workload */}}
        {{- if $hasPrimary -}}
          {{- fail "Workload - Only one workload can be primary" -}}
        {{- end -}}

        {{- $hasPrimary = true -}}

      {{- end -}}
    {{- end -}}

  {{- end -}}

  {{/* Require at least one primary workload, if any enabled */}}
  {{- if and $hasEnabled (not $hasPrimary) -}}
    {{- fail "Workload - At least one enabled workload must be primary" -}}
  {{- end -}}

{{- end -}}

{{/* Workload Basic Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.workload.basicValidation" (dict "objectData" $objectData) -}}
rootCtx: The root context of the template. It is used to access the global context.
objectData:
  labels: The labels of the object.
  annotations: The annotations of the object.
*/}}
{{- define "ix.v1.common.lib.workload.basicValidation" -}}
  {{- $objectData := .objectData -}}

  {{- if and $objectData.labels (not (kindIs "map" $objectData.labels)) -}}
    {{- fail (printf "Workload - Expected <labels> to be a dictionary, but got [%v]" (kindOf $objectData.labels)) -}}
  {{- end -}}

  {{- if and $objectData.annotations (not (kindIs "map" $objectData.annotations)) -}}
    {{- fail (printf "Workload - Expected <annotations> to be a dictionary, but got [%v]" (kindOf $objectData.annotations)) -}}
  {{- end -}}

{{- end -}}
