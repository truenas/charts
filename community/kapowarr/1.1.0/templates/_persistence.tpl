{{- define "kapowarr.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.kapowarrStorage.config.type }}
    datasetName: {{ .Values.kapowarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.kapowarrStorage.config.hostPath | default "" }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: /app/db
        01-permissions:
          mountPath: /mnt/directories/config
  downloads:
    enabled: true
    type: {{ .Values.kapowarrStorage.downloads.type }}
    datasetName: {{ .Values.kapowarrStorage.downloads.datasetName | default "" }}
    hostPath: {{ .Values.kapowarrStorage.downloads.hostPath | default "" }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: /app/temp_downloads
        01-permissions:
          mountPath: /mnt/directories/downloads
  content:
    enabled: true
    type: {{ .Values.kapowarrStorage.content.type }}
    datasetName: {{ .Values.kapowarrStorage.content.datasetName | default "" }}
    hostPath: {{ .Values.kapowarrStorage.content.hostPath | default "" }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: /content
        01-permissions:
          mountPath: /mnt/directories/content
  {{- range $idx, $storage := .Values.kapowarrStorage.additionalStorages }}
  {{ printf "kapowarr-%v" (int $idx) }}:
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
      kapowarr:
        kapowarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
