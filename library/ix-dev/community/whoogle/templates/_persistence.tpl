{{- define "whoogle.persistence" -}}
persistence:
  config:
    enabled: true
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
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      whoogle:
        whoogle:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
