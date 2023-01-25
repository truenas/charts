{{/*
Call this template like this:
{{- include "ix.v1.common.container.args" (dict "args" $args "extraArgs" $extraArgs) -}}
*/}}
{{/* Args included by the container */}}
{{- define "ix.v1.common.container.args" -}}
  {{- $args := .args -}}
  {{- $extraArgs := .extraArgs -}}

  {{- if kindIs "string" $args }} {{/* If it's single value */}}
- {{ $args | quote }}
  {{- else -}}
    {{- range $args }} {{/* args usually defined while developing the chart */}}
- {{ . | quote }}
    {{- end -}}
  {{- end -}}

  {{- if kindIs "string" $extraArgs }} {{/* If it's single value */}}
- {{ $extraArgs | quote }}
  {{- else -}}
    {{- range $extraArgs }} {{/* extraArgs used in cases that users wants to APPEND to args */}}
- {{ . | quote }}
    {{- end -}}
  {{- end -}}

{{- end -}}
