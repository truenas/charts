{{/* RBAC Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.rbac.validation" (dict "objectData" $objectData) -}}
objectData:
  labels: The labels of the rbac.
  annotations: The annotations of the rbac.
  data: The data of the rbac.
*/}}

{{- define "ix.v1.common.lib.rbac.validation" -}}
  {{- $objectData := .objectData -}}

  {{- if and $objectData.labels (not (kindIs "map" $objectData.labels)) -}}
    {{- fail (printf "RBAC - Expected <labels> to be a dictionary, but got [%v]" (kindOf $objectData.labels)) -}}
  {{- end -}}

  {{- if and $objectData.annotations (not (kindIs "map" $objectData.annotations)) -}}
    {{- fail (printf "RBAC - Expected <annotations> to be a dictionary, but got [%v]" (kindOf $objectData.annotations)) -}}
  {{- end -}}

{{- end -}}

{{/* RBAC Primary Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.rbac.primaryValidation" $ -}}
*/}}

{{- define "ix.v1.common.lib.rbac.primaryValidation" -}}

  {{/* Initialize values */}}
  {{- $hasPrimary := false -}}
  {{- $hasEnabled := false -}}

  {{- range $name, $rbac := .Values.rbac -}}

    {{/* If rbac is enabled */}}
    {{- if $rbac.enabled -}}
      {{- $hasEnabled = true -}}

      {{/* And rbac is primary */}}
      {{- if and (hasKey $rbac "primary") ($rbac.primary) -}}

        {{/* Fail if there is already a primary rbac */}}
        {{- if $hasPrimary -}}
          {{- fail "RBAC - Only one rbac can be primary" -}}
        {{- end -}}

        {{- $hasPrimary = true -}}

      {{- end -}}

    {{- end -}}
  {{- end -}}

  {{/* Require at least one primary rbac, if any enabled */}}
  {{- if and $hasEnabled (not $hasPrimary) -}}
    {{- fail "RBAC - At least one enabled rbac must be primary" -}}
  {{- end -}}

{{- end -}}
