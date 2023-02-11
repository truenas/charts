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

    {{- $types := (list "Deployment" "StatefulSet" "DaemonSet" "Job" "CronJob") -}}
    {{- if not (mustHas $workload.type $types) -}}
      {{- fail (printf "Workload - Expected <type> to be one of [%s], but got [%s]" (join ", " $types) $workload.type) -}}
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
