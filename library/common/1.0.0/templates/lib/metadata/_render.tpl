{{/* Renders a dict of labels */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $ "labels" $labels) }}
{{ include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $ "annotations" $annotations) }}
*/}}

{{- define "ix.v1.common.lib.metadata.render" -}}
  {{- $labels := .labels -}}
  {{- $annotations := .annotations -}}
  {{- $rootCtx := .rootCtx -}}

  {{- with $labels -}}
    {{- range $k, $v := . -}}
      {{- if and $k $v }}
{{ $k }}: {{ tpl $v $rootCtx | quote }}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- with $annotations -}}
    {{- range $k, $v := . -}}
      {{- if and $k $v }}
{{ $k }}: {{ tpl $v $rootCtx | quote }}
      {{- end -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
