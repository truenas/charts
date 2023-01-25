{{/* The pod definition included in the controller. */}}
{{- define "ix.v1.common.controller.pod" -}}
{{- $root := . }}
{{- $values := fromYaml (tpl ($.Values | toYaml) $) }}
serviceAccountName: {{ (include "ix.v1.common.names.serviceAccountName" $root) }}
hostNetwork: {{ $values.hostNetwork }}
enableServiceLinks: {{ $values.enableServiceLinks }}
{{- with (include "ix.v1.common.restartPolicy" (dict "restartPolicy" $values.restartPolicy "root" $root) | trim) }}
restartPolicy: {{ . }}
{{- end -}}

{{- with $values.schedulerName }}
schedulerName: {{ . }}
{{- end -}}

{{- with $values.priorityClassName }}
priorityClassName: {{ . }}
{{- end }}

{{- with $values.hostname }}
hostname: {{ . }}
{{- end -}}

{{- with (include "ix.v1.common.dnsPolicy" (dict "dnsPolicy" $values.dnsPolicy "hostNetwork" $values.hostNetwork "root" $root) | trim ) }}
dnsPolicy: {{ . }}
{{- end -}}

{{- with (include "ix.v1.common.dnsConfig" (dict "dnsPolicy" $values.dnsPolicy "dnsConfig" $values.dnsConfig "root" $root) | trim ) }}
dnsConfig:
  {{- . | nindent 2 }}
{{- end -}}

{{- with (include "ix.v1.common.hostAliases" (dict "hostAliases" $values.hostAliases "root" $root) | trim) }}
hostAliases:
  {{- . | nindent 2 }}
{{- end -}}

{{- with (include "ix.v1.common.nodeSelector" (dict "nodeSelector" $values.nodeSelector "root" $root) | trim) }}
nodeSelector:
  {{- . | nindent 2 }}
{{- end -}}

{{- with (include "ix.v1.common.tolerations" (dict "tolerations" $values.tolerations "root" $root) | trim) }}
tolerations:
  {{- . | nindent 2 }}
{{- end -}}

{{- with (include "ix.v1.common.imagePullSecrets" (dict "imagePullCredentials" $values.imagePullCredentials "root" $root) | trim) }}
imagePullSecrets:
  {{- . | nindent 2 }}
{{- end -}}

{{- with (include "ix.v1.common.runtimeClassName" (dict "root" $root "runtime" $values.runtimeClassName) | trim) }}
runtimeClassName: {{ . }}
{{- end -}}

{{/* TODO: affinity, topologySpreadConstraints, not something critical as of now. */}}
{{- with $values.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
{{- end -}}

{{- with (include "ix.v1.common.container.podSecurityContext" (dict "podSecCont" $values.podSecurityContext "root" $root) | trim) }}
securityContext:
  {{- . | nindent 2 }}
{{- end -}}

{{- with (include "ix.v1.common.controller.mainContainer" (dict "values" $values "root" $root) | trim) }}
containers:
  {{- . | nindent 2 }}
  {{- with (include "ix.v1.common.controller.extraContainers" (dict "root" $root "containerList" $values.additionalContainers "type" "additional") | trim) }}
    {{- . | nindent 2 }}
  {{- end -}}
{{- end -}}

{{- $installContainers := (include "ix.v1.common.controller.extraContainers" (dict "root" $root "containerList" $values.installContainers "type" "install") | trim) -}}
{{- $upgradeContainers := (include "ix.v1.common.controller.extraContainers" (dict "root" $root "containerList" $values.upgradeContainers "type" "upgrade") | trim) -}}
{{- $systemContainers := (include "ix.v1.common.controller.extraContainers" (dict "root" $root "containerList" $values.systemContainers "type" "system") | trim) -}}
{{- $initContainers := (include "ix.v1.common.controller.extraContainers" (dict "root" $root "containerList" $values.initContainers "type" "init") | trim) -}}

{{- if or $initContainers $systemContainers $installContainers $upgradeContainers }}
initContainers:
  {{- with $installContainers -}}
    {{- . | nindent 2 }}
  {{- end -}}

  {{- with $upgradeContainers -}}
    {{- . | nindent 2 }}
  {{- end -}}

  {{- with $systemContainers -}}
    {{- . | nindent 2 }}
  {{- end -}}

  {{- with $initContainers -}}
    {{- . | nindent 2 }}
  {{- end -}}
{{- end -}}

{{- with (include "ix.v1.common.controller.volumes" (dict "persistence" $values.persistence "root" $root) | trim) }}
volumes:
    {{- . | nindent 2 }}
{{- end -}}

{{- end -}}
