{{- define "komga.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "komga.storage.ci.migration" (dict "storage" .Values.komgaStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.komgaStorage.config) | nindent 4 }}
    targetSelector:
      komga:
        komga:
          mountPath: /config
        {{- if and (eq .Values.komgaStorage.config.type "ixVolume")
                  (not (.Values.komgaStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      komga:
        komga:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.komgaStorage.additionalStorages }}
  {{ printf "komga-%v" (int $idx) }}:
    enabled: true
    {{- include "komga.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      komga:
        komga:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "komga.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
