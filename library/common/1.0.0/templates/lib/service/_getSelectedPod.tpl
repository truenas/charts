{{/* Service - Get Selected Pod */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.getSelectedPodValues" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
objectData: The object data of the service
rootCtx: The root context of the service
*/}}

{{- define "ix.v1.common.lib.service.getSelectedPodValues" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $podValues := dict -}}
  {{- with $objectData.targetSelector -}}
    {{- $podValues = mustDeepCopy (get $rootCtx.Values.workload .) -}}

    {{- if not $podValues -}}
      {{- fail (printf "Service - Selected pod [%s] is not defined" .) -}}
    {{- end -}}

    {{- if not $podValues.enabled -}}
      {{- fail (printf "Service - Selected pod [%s] is not enabled" .) -}}
    {{- end -}}

    {{/* While we know the shortName from targetSelector, let's set it explicitly
    So service can reference this directly, to match the behaviour of a service
    without targetSelector defined (assumes "use primary") */}}
    {{- $_ := set $podValues "shortName" . -}}
  {{- else -}}

    {{/* If no targetSelector is defined, we assume the service is using the primary pod */}}
    {{/* Also no need to check for multiple primaries here, it's already done on the workload validation */}}
    {{- range $podName, $pod := $rootCtx.Values.workload -}}
      {{- if $pod.enabled -}}
        {{- if $pod.primary -}}
          {{- $podValues = mustDeepCopy $pod -}}
          {{/* Set the shortName so service can use this on selector */}}
          {{- $_ := set $podValues "shortName" $podName -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

  {{- end -}}

  {{/* Return values in Json, to preserve types */}}
  {{ $podValues | toJson }}
{{- end -}}
