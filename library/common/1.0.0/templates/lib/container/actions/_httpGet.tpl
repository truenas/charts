{{/* Returns httpGet action */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.container.actions.httpGet" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the template. It is used to access the global context.
objectData: The object data to be used to render the container.
*/}}
{{- define "ix.v1.common.lib.container.actions.httpGet" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $port := $objectData.port -}}
  {{- $path := "/" -}}
  {{- $scheme := "HTTP" -}}

  {{- if kindIs "string" $port -}}
    {{- $port = tpl $port $rootCtx -}}
  {{- end -}}
  {{- with $objectData.path -}}
    {{- $path = tpl . $rootCtx -}}
  {{- end -}}
  {{- with $objectData.scheme -}}
    {{- $scheme = tpl . $rootCtx -}}
  {{- end }}
httpGet:
  {{- with $objectData.host }}
  host: {{ tpl . $rootCtx }}
  {{- end }}
  port: {{ $port }}
  path: {{ $path }}
  scheme: {{ $scheme }}
  {{- with $objectData.httpHeaders }}
  httpHeaders:
    {{- range $name, $value := . }}
      {{- if not $value -}}
        {{- fail "Container - Expected non-empty <value> on <httpHeaders>" -}}
      {{- end }}
    - name: {{ $name }}
      value: {{ tpl (toString $value) $rootCtx  | quote }}
    {{- end -}}
  {{- end -}}

{{- end -}}
