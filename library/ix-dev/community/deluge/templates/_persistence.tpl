{{- define "deluge.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.delugeStorage.config.type }}
    datasetName: {{ .Values.delugeStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.delugeStorage.config.hostPath | default "" }}
    targetSelector:
      deluge:
        deluge:
          mountPath: /config
        config:
          mountPath: /config
  downloads:
    enabled: true
    type: {{ .Values.delugeStorage.downloads.type }}
    datasetName: {{ .Values.delugeStorage.downloads.datasetName | default "" }}
    hostPath: {{ .Values.delugeStorage.downloads.hostPath | default "" }}
    targetSelector:
      deluge:
        deluge:
          mountPath: /downloads
  {{- range $idx, $storage := .Values.delugeStorage.additionalStorages }}
  {{ printf "deluge-%v" (int $idx) }}:
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
      deluge:
        deluge:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
