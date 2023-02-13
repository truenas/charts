{{/* Returns lifecycle */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.container.lifecycle" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the container.
*/}}
{{- define "ix.v1.common.lib.container.lifecycle" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $hooks := (list "preStop" "postStart") -}}
  {{- $types := (list "EXEC" "HTTP" "HTTPS") -}}
  {{- with $objectData.lifecycle -}}
    {{- range $hook, $hookValues := . -}}
      {{- if not (mustHas $hook $hooks) -}}
        {{- fail (printf "Container - Expected <lifecycle> <hook> to be one of [%s], but got [%s]" (join ", " $hooks) $hook) -}}
      {{- end -}}

      {{- if not $hookValues.type -}}
        {{- fail "Container - Expected non-empty <lifecycle> <type>" -}}
      {{- end -}}

      {{- if not (mustHas $hookValues.type $types) -}}
        {{- fail (printf "Container - Expected <lifecycle> <type> to be one of [%s], but got [%s]" (join ", " $types) $hookValues.type) -}}
      {{- end }}
{{ $hook }}:
      {{- if eq $hookValues.type "EXEC" -}}
        {{- include "ix.v1.common.lib.container.actions.exec" (dict "rootCtx" $rootCtx "objectData" $hookValues "caller" "lifecycle") | trim | nindent 2 -}}
      {{- else if mustHas $hookValues.type (list "HTTP" "HTTPS") -}}
        {{- include "ix.v1.common.lib.container.actions.httpGet" (dict "rootCtx" $rootCtx "objectData" $hookValues "caller" "lifecycle") | trim | nindent 2 -}}
      {{- end -}}

    {{- end -}}
  {{- end -}}


{{- end -}}
