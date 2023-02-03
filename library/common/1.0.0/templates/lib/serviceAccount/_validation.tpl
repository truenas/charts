{{/* Service Account Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.serviceAccount.validation" (dict "objectData" $objectData) -}}
objectData:
  labels: The labels of the serviceAccount.
  annotations: The annotations of the serviceAccount.
*/}}

{{- define "ix.v1.common.lib.serviceAccount.validation" -}}
  {{- $objectData := .objectData -}}

  {{- if and $objectData.labels (not (kindIs "map" $objectData.labels)) -}}
    {{- fail (printf "Service Account - Expected <labels> to be a dictionary, but got [%v]" (kindOf $objectData.labels)) -}}
  {{- end -}}

  {{- if and $objectData.annotations (not (kindIs "map" $objectData.annotations)) -}}
    {{- fail (printf "Service Account - Expected <annotations> to be a dictionary, but got [%v]" (kindOf $objectData.annotations)) -}}
  {{- end -}}

{{- end -}}

{{/* Service Account Primary Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.serviceAccount.primaryValidation" $ -}}
*/}}

{{- define "ix.v1.common.lib.serviceAccount.primaryValidation" -}}

  {{/* Initialize values */}}
  {{- $hasPrimary := false -}}
  {{- $hasEnabled := false -}}

  {{- range $name, $serviceAccount := .Values.serviceAccount -}}

    {{/* If service account is enabled */}}
    {{- if $serviceAccount.enabled -}}
      {{- $hasEnabled = true -}}

      {{/* And service account is primary */}}
      {{- if and (hasKey $serviceAccount "primary") ($serviceAccount.primary) -}}

        {{/* Fail if there is already a primary service account */}}
        {{- if $hasPrimary -}}
          {{- fail "Service Account - Only one service account can be primary" -}}
        {{- end -}}

        {{- $hasPrimary = true -}}

      {{- end -}}

    {{- end -}}
  {{- end -}}

  {{/* Require at least one primary service account, if any enabled */}}
  {{- if and $hasEnabled (not $hasPrimary) -}}
    {{- fail "Service Account - At least one enabled service account must be primary" -}}
  {{- end -}}

{{- end -}}
