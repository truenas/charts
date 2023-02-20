{{/* Annotations that are added to all objects */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.metadata.allAnnotations" $ }}
*/}}
{{- define "ix.v1.common.lib.metadata.allAnnotations" -}}
  {{/* Currently empty but can add later, if needed */}}
{{- include "ix.v1.common.lib.metadata.globalAnnotations" . }}

{{- end -}}
