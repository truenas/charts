{{/*
Call this template like this:
{{- include "ix.v1.common.container.args" (dict "commands" $commands) -}}
*/}}
{{/* Command included by the container */}}
{{- define "ix.v1.common.container.command" -}}
  {{- $commands := .commands -}}

  {{- if kindIs "string" $commands }}
- {{ $commands | quote }}
  {{- else -}}
    {{- range $commands }}
- {{ . | quote }}
    {{- end -}}
  {{- end -}}

{{- end -}}
