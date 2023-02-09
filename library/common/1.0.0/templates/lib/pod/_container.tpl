{{/* Returns Container */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.container" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the template. It is used to access the global context.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.container" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

{{- end -}}
