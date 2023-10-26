{{- define "readarr.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.readarrStorage.config.type }}
    datasetName: {{ .Values.readarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.readarrStorage.config.hostPath | default "" }}
    targetSelector:
      readarr:
        readarr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      readarr:
        readarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.readarrStorage.additionalStorages }}
  {{ printf "readarr-%v" (int $idx) }}:
    {{- $size := "" -}}
    {{- if $storage.size -}}
      {{- $size = (printf "%vGi" $storage.size) -}}
    {{- end }}
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    server: {{ $storage.server | default "" }}
    share: {{ $storage.share | default "" }}
    domain: {{ $storage.domain | default "" }}
    username: {{ $storage.username | default "" }}
    password: {{ $storage.password | default "" }}
    size: {{ $size }}
    {{- if eq $storage.type "smb-pv-pvc" }}
    mountOptions:
      - key: noperm
    {{- end }}
    targetSelector:
      readarr:
        readarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
