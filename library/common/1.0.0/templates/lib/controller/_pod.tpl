{{/* Pod Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.controller.pod" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the template. It is used to access the global context.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.controller.pod" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- with (include "ix.v1.common.lib.pod.imagePullSecrets" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
imagePullSecrets:
    {{-  . | nindent 2 }}
  {{- end }}
hostNetwork: {{ include "ix.v1.common.lib.pod.hostNetwork" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
enableServiceLinks: {{ include "ix.v1.common.lib.pod.enableServiceLinks" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
restartPolicy: {{ include "ix.v1.common.lib.pod.restartPolicy" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
  {{- with include "ix.v1.common.lib.pod.schedulerName" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
schedulerName: {{ . }}
  {{- end }}
{{- end -}}
