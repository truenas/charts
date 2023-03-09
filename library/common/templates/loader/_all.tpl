{{/* Main entrypoint for the library */}}
{{- define "ix.v1.common.loader.all" -}}

  {{- include "ix.v1.common.loader.init" . -}}

  {{- include "ix.v1.common.loader.apply" . -}}

{{- end -}}
