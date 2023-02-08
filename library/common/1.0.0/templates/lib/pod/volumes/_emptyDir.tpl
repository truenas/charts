{{/* Returns emptyDir Volume */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.volume.emptyDir" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the template. It is used to access the global context.
objectData: The object data to be used to render the volume.
*/}}
{{- define "ix.v1.common.lib.pod.volume.emptyDir" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $medium := "" -}}
  {{- $size := "" -}}
  {{- with $objectData.medium -}}
    {{- $medium = tpl . $rootCtx -}}
  {{- end -}}
  {{- with $objectData.size -}}
    {{- $size = tpl . $rootCtx -}}
  {{- end -}}

  {{- if and $medium (ne $medium "Memory") -}}
    {{- fail (printf "Persistence - Expected [medium] to be one of [\"\", Memory], but got [%s] on <emptyDir> type" $medium)  -}}
  {{- end }}
- name: {{ $objectData.shortName }}
  {{- if or $medium $size }}
  emptyDir:
    {{- if $medium }}
    medium: {{ $medium }}
    {{- end -}}
    {{- if $size }}
    sizeLimit: {{ $size }}
    {{- end -}}
  {{- else }}
  emptyDir: {}
  {{- end -}}
{{- end -}}
