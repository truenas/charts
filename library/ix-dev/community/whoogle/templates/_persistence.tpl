{{- define "whoogle.persistence" -}}
persistence:
  config:
    enabled: true
    # Upstream also has this dir
    # in an tmpfs directory
    type: emptyDir
    targetSelector:
      whoogle:
        whoogle:
          mountPath: /config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      whoogle:
        whoogle:
          mountPath: /tmp
  runtor:
    enabled: true
    type: emptyDir
    targetSelector:
      whoogle:
        whoogle:
          mountPath: /run/tor
  varlibtor:
    enabled: true
    type: emptyDir
    targetSelector:
      whoogle:
        whoogle:
          mountPath: /var/lib/tor
        # emptyDir is by default 0:fsGroup
        # But for this directory we need to set it to 927:927
        01-permissions:
          mountPath: /mnt/directories/varlibtor

  {{- range $idx, $storage := .Values.whoogleStorage.additionalStorages }}
  {{ printf "whoogle-%v" (int $idx) }}:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      whoogle:
        whoogle:
          mountPath: {{ $storage.mountPath }}
      {{- if $.Release.IsInstall }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
      {{- end }}
  {{- end }}
{{- end -}}
