{{/* CronJob Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.workload.cronjobValidation" (dict "objectData" $objectData) -}}
rootCtx: The root context of the template. It is used to access the global context.
objectData:
  completionMode: The completionMode of the object.
  completions: The completions of the object.
  parallelism: The parallelism of the object.
*/}}
{{- define "ix.v1.common.lib.workload.cronjobValidation" -}}
  {{- $objectData := .objectData -}}

  {{- if $objectData.concurrencyPolicy -}}
    {{- $concurrencyPolicy := $objectData.concurrencyPolicy -}}

    {{- if not (mustHas $concurrencyPolicy (list "Allow" "Forbid" "Replace")) -}}
      {{- fail (printf "CronJob - Expected <concurrencyPolicy> to be one of [Allow, Forbid, Replace], but got [%v]" $concurrencyPolicy) -}}
    {{- end -}}

  {{- end -}}

  {{- if not $objectData.schedule -}}
    {{- fail "CronJob - Expected non-empty <schedule>" -}}
  {{- end -}}

  {{/* CronJob contains a job inside, so we validate job values too */}}
  {{- include "ix.v1.common.lib.workload.jobValidation" (dict "objectData" $objectData) -}}
{{- end -}}
{{/* TODO: Extend validation for other values of cronjob */}}
