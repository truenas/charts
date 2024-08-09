{{- define "frigate.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "frigate.storage.ci.migration" (dict "storage" .Values.frigateStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.frigateStorage.config) | nindent 4 }}
    targetSelector:
      frigate:
        frigate:
          mountPath: /config
        01-init:
          mountPath: /config
  media:
    enabled: true
    {{- include "frigate.storage.ci.migration" (dict "storage" .Values.frigateStorage.media) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.frigateStorage.media) | nindent 4 }}
    targetSelector:
      frigate:
        frigate:
          mountPath: /media
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      frigate:
        frigate:
          mountPath: /tmp
  cache:
    enabled: true
    type: emptyDir
    medium: Memory
    size: {{ printf "%vGi" .Values.frigateStorage.cache.sizeGiB }}
    targetSelector:
      frigate:
        frigate:
          mountPath: /tmp/cache
  shm:
    enabled: true
    type: emptyDir
    medium: Memory
    size: {{ printf "%vMi" .Values.frigateStorage.shm.sizeMiB }}
    targetSelector:
      frigate:
        frigate:
          mountPath: /dev/shm
  {{- if .Values.frigateConfig.mountUSBBus }}
  usb-bus:
    enabled: true
    type: hostPath
    hostPath: /dev/bus/usb
    targetSelector:
      frigate:
        frigate:
          mountPath: /dev/bus/usb
  {{- end -}}
  {{- range $idx, $storage := .Values.frigateStorage.additionalStorages }}
  {{ printf "frigate-%v:" (int $idx) }}
    enabled: true
    {{- include "frigate.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      frigate:
        frigate:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "frigate.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
