{{/* Returns Container */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.container" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.container" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $imageObj := fromJson (include "ix.v1.common.lib.container.imageSelector" (dict "rootCtx" $rootCtx "objectData" $objectData)) -}}
  {{- $termination := fromJson (include "ix.v1.common.lib.container.termination" (dict "rootCtx" $rootCtx "objectData" $objectData)) }}
- name: {{ $objectData.name }}
  image: {{ printf "%s:%s" $imageObj.repository $imageObj.tag }}
  imagePullPolicy: {{ $imageObj.pullPolicy }}
  tty: {{ $objectData.tty | default false }}
  stdin: {{ $objectData.stdin | default false }}
  {{- with (include "ix.v1.common.lib.container.command" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
  command:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- with (include "ix.v1.common.lib.container.args" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
  args:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- with $termination.messagePath }}
  terminationMessagePath: {{ . }}
  {{- end -}}
  {{- with $termination.messagePolicy }}
  terminationMessagePolicy: {{ . }}
  {{- end -}}
  {{- with (include "ix.v1.common.lib.container.lifecycle" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
  lifecycle:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- with (include "ix.v1.common.lib.container.ports" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
  ports:
    {{- . | nindent 4 }}
  {{- end -}}
{{- end -}}

{{/* TODO:
probes

env
envList
fixedEnv
envFrom

securityContext
resources
volumeMounts
*/}}
