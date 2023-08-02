{{/* Returns Volumes */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.volumes" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.volumes" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- range $name, $persistenceValues := $rootCtx.Values.persistence -}}
    {{- if $persistenceValues.enabled -}}

      {{- $persistence := (mustDeepCopy $persistenceValues) -}}

      {{- $_ := set $persistence "shortName" $name -}}
      {{- $_ := set $persistence "type" ($persistence.type | default $rootCtx.Values.fallbackDefaults.persistenceType) -}}

      {{- $selected := false -}}

      {{/* If set to true, define volume */}}
      {{- if $persistence.targetSelectAll -}}
        {{- $selected = true -}}

      {{/* If targetSelector is set, check if pod is selected */}}
      {{- else if $persistence.targetSelector -}}
        {{- if (mustHas $objectData.shortName (keys $persistence.targetSelector)) -}}
          {{- $selected = true -}}
        {{- end -}}

      {{/* If no targetSelector is set or targetSelectAll, check if pod is primary */}}
      {{- else -}}
        {{- if $objectData.primary -}}
          {{- $selected = true -}}
        {{- end -}}
      {{- end -}}

      {{/* If pod selected */}}
      {{- if $selected -}}
        {{/* Define the volume based on type */}}
        {{- $type := ($persistence.type | default $rootCtx.Values.fallbackDefaults.persistenceType) -}}

        {{- if eq "ixVolume" $type -}}
          {{- include "ix.v1.common.lib.pod.volume.ixVolume" (dict "rootCtx" $rootCtx "objectData" $persistence) | trim | nindent 0 -}}
        {{- else if eq "hostPath" $type -}}
          {{- include "ix.v1.common.lib.pod.volume.hostPath" (dict "rootCtx" $rootCtx "objectData" $persistence) | trim | nindent 0 -}}
        {{- else if eq "secret" $type -}}
          {{- include "ix.v1.common.lib.pod.volume.secret" (dict "rootCtx" $rootCtx "objectData" $persistence) | trim | nindent 0 -}}
        {{- else if eq "configmap" $type -}}
          {{- include "ix.v1.common.lib.pod.volume.configmap" (dict "rootCtx" $rootCtx "objectData" $persistence) | trim | nindent 0 -}}
        {{- else if eq "emptyDir" $type -}}
          {{- include "ix.v1.common.lib.pod.volume.emptyDir" (dict "rootCtx" $rootCtx "objectData" $persistence) | trim | nindent 0 -}}
        {{- else if eq "device" $type -}}
          {{- include "ix.v1.common.lib.pod.volume.device" (dict "rootCtx" $rootCtx "objectData" $persistence) | trim | nindent 0 -}}
        {{- else if (mustHas $type (list "smb-pv-pvc" "nfs-pv-pvc" "ix-zfs-pvc" "pvc")) -}}
          {{- include "ix.v1.common.lib.pod.volume.pvc" (dict "rootCtx" $rootCtx "objectData" $persistence) | trim | nindent 0 -}}
        {{- end -}}

      {{- end -}}

    {{- end -}}
  {{- end -}}
{{- end -}}
