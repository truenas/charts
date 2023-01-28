{{/* This will be used when the (cron)job pod is deployed along with a "main" pod */}}
{{- define "ix.v1.common.job.pod" -}}
{{- $root := .root -}}
{{- $values := .values -}}
{{- $inherit := "inherit" -}}

{{/* Prepare values */}}
{{- $saName := "" -}}
{{- with $values.serviceAccountName -}}
  {{- if eq . $inherit -}}
    {{- $saName = (include "ix.v1.common.names.serviceAccountName" $root) -}}
  {{- else -}}
    {{- $saName = . -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $hostNet := false -}}
{{- if hasKey $values "hostNetwork" -}}
  {{- if eq (toString $values.hostNetwork) $inherit }}
    {{ $hostNet = $root.Values.hostNetwork }}
  {{- else if (kindIs "bool" $values.hostNetwork) }}
    {{ $hostNet =  $values.hostNetwork }}
  {{- end -}}
{{- end -}}

{{- $schedulerName := "" -}}
{{- with $values.schedulerName -}}
  {{- if eq . $inherit -}}
    {{- $schedulerName = (tpl $root.Values.controllers.main.pod.schedulerName $root) -}}
  {{- else -}}
    {{- $schedulerName = . -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $priorityClassName := "" -}}
{{- with $values.priorityClassName -}}
  {{- if eq . $inherit -}}
    {{- $priorityClassName = (tpl $root.Values.controllers.main.pod.priorityClassName $root) -}}
  {{- else -}}
    {{- $priorityClassName = . -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $hostname := "" -}}
{{- with $values.hostname -}}
  {{- if eq . $inherit -}}
    {{- $hostname = (tpl $root.Values.controllers.main.pod.hostname $root) -}}
  {{- else  -}}
    {{- $hostname = . -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $dnsPolicy := "" -}}
{{- with $values.dnsPolicy -}}
  {{- if eq . $inherit -}}
    {{- with (include "ix.v1.common.dnsPolicy" (dict "dnsPolicy" $root.Values.dnsPolicy "hostNetwork" $root.Values.hostNetwork "root" $root) | trim ) -}}
      {{- $dnsPolicy = . -}}
    {{- end -}}
  {{- else -}}
    {{- with (include "ix.v1.common.dnsPolicy" (dict "dnsPolicy" $values.dnsPolicy "hostNetwork" ($values.hostNetwork | default false) "root" $root) | trim ) -}}
      {{- $dnsPolicy = . -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $dnsConfig := dict -}}
{{- with $values.dnsConfig -}}
  {{- if eq (toString .) $inherit -}}
    {{- with (include "ix.v1.common.dnsConfig" (dict "dnsPolicy" $root.Values.controllers.main.pod.dnsPolicy "dnsConfig" $root.Values.controllers.main.pod.dnsConfig "root" $root) | trim ) -}}
      {{- $dnsConfig = . -}}
    {{- end -}}
  {{- else -}}
    {{- with (include "ix.v1.common.dnsConfig" (dict "dnsPolicy" ($dnsPolicy | default $root.Values.controllers.main.pod.dnsPolicy) "dnsConfig" $values.dnsConfig "root" $root) | trim ) -}}
      {{- $dnsConfig = . -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $hostAliases := dict -}}
{{- with $values.hostAliases -}}
  {{- if eq (toString .) $inherit -}}
    {{- with (include "ix.v1.common.hostAliases" (dict "hostAliases" $root.Values.controllers.main.pod.hostAliases "root" $root) | trim) -}}
      {{- $hostAliases = . -}}
    {{- end -}}
  {{- else -}}
    {{- with (include "ix.v1.common.hostAliases" (dict "hostAliases" $values.hostAliases "root" $root) | trim) -}}
      {{- $hostAliases = . -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $nodeSelector := "" -}}
{{- with $values.nodeSelector -}}
  {{- if eq (toString .) $inherit -}}
    {{- with (include "ix.v1.common.nodeSelector" (dict "nodeSelector" $root.Values.controllers.main.pod.nodeSelector "root" $root) | trim) -}}
      {{- $nodeSelector = . -}}
    {{- end -}}
  {{- else -}}
    {{- with (include "ix.v1.common.nodeSelector" (dict "nodeSelector" $values.nodeSelector "root" $root) | trim) -}}
      {{- $nodeSelector = . -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $tolerations := dict -}}
{{- with $values.tolerations -}}
  {{- if eq (toString .) $inherit -}}
    {{- with (include "ix.v1.common.tolerations" (dict "tolerations" $root.Values.controllers.main.pod.tolerations "root" $root) | trim) -}}
      {{- $tolerations = . -}}
    {{- end -}}
  {{- else -}}
    {{- with (include "ix.v1.common.tolerations" (dict "tolerations" $values.tolerations "root" $root) | trim) -}}
      {{- $tolerations = . -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $imagePullSecrets := dict -}}
{{- with $values.imagePullSecrets -}}
  {{- if eq (toString .) $inherit -}}
    {{- with (include "ix.v1.common.imagePullSecrets" (dict "imagePullCredentials" $root.Values.imagePullCredentials "root" $root) | trim) -}}
      {{- $imagePullSecrets = . -}}
    {{- end -}}
  {{- else -}}
    {{- with (include "ix.v1.common.imagePullSecrets" (dict "imagePullCredentials" $values.imagePullCredentials "root" $root) | trim) -}}
      {{- $imagePullSecrets = . -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $runtimeClassName := "" -}}
{{- with $values.runtimeClassName -}}
  {{- if eq . $inherit -}}
    {{- with (include "ix.v1.common.runtimeClassName" (dict "root" $root "runtime" $root.Values.controllers.main.pod.runtimeClassName) | trim) -}}
      {{- $runtimeClassName = . -}}
    {{- end -}}
  {{- else -}}
    {{- $runtimeClassName = . -}}
  {{- end -}}
{{- else -}}
  {{- with (include "ix.v1.common.runtimeClassName" (dict "root" $root "runtime" $root.Values.controllers.main.pod.runtimeClassName "isJob" true) | trim) -}}
    {{- $runtimeClassName = . -}}
  {{- end -}}
{{- end -}}
{{- $termSeconds := "" -}}
{{- with $values.terminationGracePeriodSeconds -}}
  {{- if eq (toString .) $inherit -}}
    {{- with $root.Values.controllers.main.pod.terminationGracePeriodSeconds -}}
      {{- $termSeconds = . -}}
    {{- end -}}
  {{- else -}}
    {{- with $values.terminationGracePeriodSeconds -}}
      {{- $termSeconds = . -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{/* If we ever have value in globalDefaults */}}
{{- end -}}

{{- $secCont := dict -}}
{{- with $values.podSecurityContext -}}
  {{- if eq (toString .) $inherit -}} {{/* If inherti is set, use the main podSecCont */}}
    {{- with (include "ix.v1.common.container.podSecurityContext" (dict "podSecCont" $root.Values.controllers.main.pod.securityContext "root" $root "isJob" true) | trim) -}}
      {{- $secCont = . -}}
    {{- end -}}
  {{- else -}} {{/* Otherwise use the job's podpodSecCont values */}}
    {{- with (include "ix.v1.common.container.podSecurityContext" (dict "podSecCont" $values.podSecurityContext "root" $root "isJob" true) | trim) -}}
      {{- $secCont = . -}}
    {{- end -}}
  {{- end -}}
{{- else -}} {{/* Otherwise use the job's podSecCont values (if empty, will use the global defaults) */}}
  {{- with (include "ix.v1.common.container.podSecurityContext" (dict "podSecCont" $values.podSecurityContext "root" $root "isJob" true) | trim) -}}
    {{- $secCont = . -}}
  {{- end -}}
{{- end -}}

{{/* Now render the actual values */}}
hostNetwork: {{ $hostNet }}

{{- if hasKey $values "enableServiceLinks" -}}
  {{- if eq (toString $values.enableServiceLinks) $inherit }}
enableServiceLinks: {{ $root.Values.controllers.main.pod.enableServiceLinks }}
  {{- else if (kindIs "bool" $values.enableServiceLinks) }}
enableServiceLinks: {{ $values.enableServiceLinks }}
  {{- end -}}
{{- else }}
enableServiceLinks: false
{{- end -}}

{{- with $saName }}
serviceAccountName: {{ . }}
{{- end -}}

{{- with (include "ix.v1.common.restartPolicy" (dict "restartPolicy" $values.restartPolicy "isJob" true "root" $root) | trim) }}
restartPolicy: {{ . }}
{{- end -}}

{{- with $schedulerName }}
schedulerName: {{ . }}
{{- end -}}

{{- with $priorityClassName }}
priorityClassName: {{ . }}
{{- end -}}

{{- with $hostname }}
hostname: {{ . }}
{{- end -}}

{{- with $dnsPolicy }}
dnsPolicy: {{ . }}
{{- end -}}

{{- with $dnsConfig }}
dnsConfig:
  {{- . | nindent 2 }}
{{- end -}}

{{- with $hostAliases }}
hostAliases:
  {{- . | nindent 2 }}
{{- end -}}

{{- with $nodeSelector }}
nodeSelector:
  {{- . | nindent 2 }}
{{- end -}}

{{- with $tolerations }}
tolerations:
  {{- . | nindent 2 }}
{{- end -}}

{{- with $imagePullSecrets }}
imagePullSecrets:
  {{- . | nindent 2 }}
{{- end -}}

{{- with $runtimeClassName }}
runtimeClassName: {{ . }}
{{- end -}}

{{- with $termSeconds }}
terminationGracePeriodSeconds: {{ . }}
{{- end }}
securityContext:
  {{- $secCont | nindent 2 }}

{{- with (include "ix.v1.common.controller.extraContainers" (dict "root" $root "containerList" $values.containers "type" "job") | trim) }}
containers:
  {{- . | nindent 2 }}
{{- end -}}

{{- with (include "ix.v1.common.controller.volumes" (dict "persistence" $root.Values.persistence "root" $root) | trim) }}
volumes:
    {{- . | nindent 2 }}
{{- end -}}
{{- end -}}
