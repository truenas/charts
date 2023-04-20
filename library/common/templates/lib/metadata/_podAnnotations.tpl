{{/* Annotations that are added to podSpec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.metadata.podAnnotations" $ }}
*/}}
{{- define "ix.v1.common.lib.metadata.podAnnotations" -}}
rollme: {{ randAlphaNum 5 | quote }}
{{- end -}}
