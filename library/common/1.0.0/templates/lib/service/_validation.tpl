{{/* Service Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.validation" (dict "objectData" $objectData) -}}
objectData:
  labels: The labels of the service.
  annotations: The annotations of the service.
*/}}

{{- define "ix.v1.common.lib.service.validation" -}}
  {{- $objectData := .objectData -}}

  {{- if and $objectData.labels (not (kindIs "map" $objectData.labels)) -}}
    {{- fail (printf "Service - Expected <labels> to be a dictionary, but got [%v]" (kindOf $objectData.labels)) -}}
  {{- end -}}

  {{- if and $objectData.annotations (not (kindIs "map" $objectData.annotations)) -}}
    {{- fail (printf "Service - Expected <annotations> to be a dictionary, but got [%v]" (kindOf $objectData.annotations)) -}}
  {{- end -}}

  {{- if and $objectData.targetSelector (not (kindIs "string" $objectData.targetSelector)) -}}
    {{- fail (printf "Service - Expected service's <targetSelector> to be [string], but got [%s]" (kindOf $objectData.targetSelector)) -}}
  {{- end -}}

  {{- $hasEnabledPort := false -}}
  {{- range $name, $port := $objectData.ports -}}
    {{- if $port.enabled -}}
      {{- $hasEnabledPort = true -}}

      {{- if and $port.targetSelector (not (kindIs "string" $port.targetSelector)) -}}
        {{- fail (printf "Service - Expected port's <targetSelector> to be [string], but got [%s]" (kindOf $port.targetSelector)) -}}
      {{- end -}}

      {{- if and $port.protocol (not (mustHas $port.protocol (list "TCP" "UDP" "HTTP" "HTTPS"))) -}}
        {{- fail (printf "Service - Expected port's protocol to be one of [TCP, UDP, HTTP, HTTPS] but got [%s]" $port.protocol) -}}
      {{- end -}}

    {{- end -}}
  {{- end -}}

  {{- if not $hasEnabledPort -}}
    {{- fail "Service - Expected enabled service to have at least one port" -}}
  {{- end -}}

{{- end -}}

{{/* Service Primary Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.primaryValidation" $ -}}
*/}}

{{- define "ix.v1.common.lib.service.primaryValidation" -}}

  {{/* Initialize values */}}
  {{- $hasPrimary := false -}}
  {{- $hasEnabled := false -}}

  {{- range $name, $service := .Values.service -}}

    {{/* If service is enabled */}}
    {{- if $service.enabled -}}
      {{- $hasEnabled = true -}}

      {{/* And service is primary */}}
      {{- if and (hasKey $service "primary") ($service.primary) -}}
        {{/* Fail if there is already a primary service */}}
        {{- if $hasPrimary -}}
          {{- fail "Service - Only one service can be primary" -}}
        {{- end -}}

        {{- $hasPrimary = true -}}

        {{- include "ix.v1.common.lib.servicePort.primaryValidation" (dict "objectData" $service.ports) -}}

      {{- end -}}

    {{- end -}}
  {{- end -}}

  {{/* Require at least one primary service, if any enabled */}}
  {{- if and $hasEnabled (not $hasPrimary) -}}
    {{- fail "Service - At least one enabled service must be primary" -}}
  {{- end -}}

{{- end -}}

{{/* Service Port Primary Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.primaryValidation" (dict "objectData" $objectData -}}
objectData:
  The ports of the service.
*/}}

{{- define "ix.v1.common.lib.servicePort.primaryValidation" -}}
  {{- $objectData := .objectData -}}

  {{/* Initialize values */}}
  {{- $hasPrimary := false -}}
  {{- $hasEnabled := false -}}

  {{- range $name, $port := $objectData -}}

    {{/* If service is enabled */}}
    {{- if $port.enabled -}}
      {{- $hasEnabled = true -}}

      {{/* And service is primary */}}
      {{- if and (hasKey $port "primary") ($port.primary) -}}

        {{/* Fail if there is already a primary port */}}
        {{- if $hasPrimary -}}
          {{- fail "Service - Only one port per service can be primary" -}}
        {{- end -}}

        {{- $hasPrimary = true -}}

      {{- end -}}

    {{- end -}}
  {{- end -}}

  {{/* Require at least one primary service, if any enabled */}}
  {{- if and $hasEnabled (not $hasPrimary) -}}
    {{- fail "Service - At least one enabled port in service must be primary" -}}
  {{- end -}}

{{- end -}}
