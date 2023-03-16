{{/* Service Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.validation" (dict "objectData" $objectData) -}}
objectData:
  rootCtx: The root context of the chart.
  objectData: The service object.
*/}}

{{- define "ix.v1.common.lib.service.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if and $objectData.targetSelector (not (kindIs "string" $objectData.targetSelector)) -}}
    {{- fail (printf "Service - Expected <targetSelector> to be [string], but got [%s]" (kindOf $objectData.targetSelector)) -}}
  {{- end -}}

  {{- $svcTypes := (list "ClusterIP" "NodePort") -}}
  {{- if and $objectData.type (not (mustHas $objectData.type $svcTypes)) -}}
    {{- fail (printf "Service - Expected <type> to be one of [%s] but got [%s]" (join ", " $svcTypes) $objectData.type) -}}
  {{- end -}}

  {{- $hasEnabledPort := false -}}
  {{- range $name, $port := $objectData.ports -}}
    {{- if $port.enabled -}}
      {{- $hasEnabledPort = true -}}

      {{- if and $port.targetSelector (not (kindIs "string" $port.targetSelector)) -}}
        {{- fail (printf "Service - Expected <port.targetSelector> to be [string], but got [%s]" (kindOf $port.targetSelector)) -}}
      {{- end -}}

      {{- if not $port.port -}}
        {{- fail (printf "Service - Expected non-empty <port.port>") -}}
      {{- end -}}

      {{- $protocolTypes := (list "tcp" "udp" "http" "https") -}}
      {{- if $port.protocol -}}
        {{- if not (mustHas (tpl $port.protocol $rootCtx) $protocolTypes) -}}
          {{- fail (printf "Service - Expected <port.protocol> to be one of [%s] but got [%s]" (join ", " $protocolTypes) $port.protocol) -}}
        {{- end -}}
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
