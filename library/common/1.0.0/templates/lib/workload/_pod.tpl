{{/* Pod Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.workload.pod" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.workload.pod" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
serviceAccountName: {{ include "ix.v1.common.lib.pod.serviceAccountName" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
automountServiceAccountToken: {{ include "ix.v1.common.lib.pod.automountServiceAccountToken" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
runtimeClassName: {{ include "ix.v1.common.lib.pod.runtimeClassName" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
  {{- with (include "ix.v1.common.lib.pod.imagePullSecret" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
imagePullSecrets:
    {{-  . | nindent 2 }}
  {{- end }}
hostNetwork: {{ include "ix.v1.common.lib.pod.hostNetwork" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
enableServiceLinks: {{ include "ix.v1.common.lib.pod.enableServiceLinks" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
restartPolicy: {{ include "ix.v1.common.lib.pod.restartPolicy" (dict "rootCtx" $rootCtx "objectData" $objectData) }}
  {{- with (include "ix.v1.common.lib.pod.hostAliases" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
hostAliases:
    {{- . | nindent 2 }}
  {{- end -}}
  {{- with (include "ix.v1.common.lib.pod.hostname" (dict "rootCtx" $rootCtx "objectData" $objectData)) }}
hostname: {{ . }}
  {{- end -}}
  {{- include "ix.v1.common.lib.pod.dns" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
  {{- with (include "ix.v1.common.lib.pod.terminationGracePeriodSeconds" (dict "rootCtx" $rootCtx "objectData" $objectData)) }}
terminationGracePeriodSeconds: {{ . }}
  {{- end -}}
  {{- with (include "ix.v1.common.lib.pod.tolerations" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
tolerations:
    {{- . | nindent 2 }}
  {{- end }}
securityContext:
  {{- include "ix.v1.common.lib.pod.securityContext" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 }}
  {{- if $objectData.podSpec.containers }}
containers:
    {{- include "ix.v1.common.lib.pod.containerSpawner" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 -}}
  {{- end -}}
  {{- if $objectData.podSpec.initContainers }}
initContainers:
    {{- include "ix.v1.common.lib.pod.initContainerSpawner" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 -}}
  {{- end -}}
  {{- with (include "ix.v1.common.lib.pod.volumes" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
volumes:
  {{- . | nindent 2 }}
{{- end -}}
{{- end -}}
