{{- define "sabnzbd.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "sabnzbd.storage.ci.migration" (dict "storage" .Values.sabnzbdStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.sabnzbdStorage.config) | nindent 4 }}
    targetSelector:
      sabnzbd:
        sabnzbd:
          mountPath: /config
        {{- if and (eq .Values.sabnzbdStorage.config.type "ixVolume")
                  (not (.Values.sabnzbdStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      sabnzbd:
        sabnzbd:
          mountPath: /tmp

  {{- range $idx, $storage := .Values.sabnzbdStorage.additionalStorages }}
  {{ printf "sabnzbd-%v" (int $idx) }}:
    enabled: true
    {{- include "sabnzbd.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      sabnzbd:
        sabnzbd:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "sabnzbd.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
