{{- define "pigallery.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.pigalleryStorage.config.type }}
    datasetName: {{ .Values.pigalleryStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.pigalleryStorage.config.hostPath | default "" }}
    targetSelector:
      pigallery:
        pigallery:
          mountPath: /app/data/config
        01-permissions:
          mountPath: /mnt/directories/config
  db:
    enabled: true
    type: {{ .Values.pigalleryStorage.db.type }}
    datasetName: {{ .Values.pigalleryStorage.db.datasetName | default "" }}
    hostPath: {{ .Values.pigalleryStorage.db.hostPath | default "" }}
    targetSelector:
      pigallery:
        pigallery:
          mountPath: /app/data/db
        01-permissions:
          mountPath: /mnt/directories/db
  media:
    enabled: true
    type: {{ .Values.pigalleryStorage.media.type }}
    datasetName: {{ .Values.pigalleryStorage.media.datasetName | default "" }}
    hostPath: {{ .Values.pigalleryStorage.media.hostPath | default "" }}
    targetSelector:
      pigallery:
        pigallery:
          mountPath: /app/data/media
        01-permissions:
          mountPath: /mnt/directories/media
  thumbnails:
    enabled: true
    type: {{ .Values.pigalleryStorage.thumbnails.type }}
    datasetName: {{ .Values.pigalleryStorage.thumbnails.datasetName | default "" }}
    hostPath: {{ .Values.pigalleryStorage.thumbnails.hostPath | default "" }}
    targetSelector:
      pigallery:
        pigallery:
          mountPath: /app/data/thumbnails
        01-permissions:
          mountPath: /mnt/directories/thumbnails
  {{- range $idx, $storage := .Values.pigalleryStorage.additionalStorages }}
  {{ printf "pigallery-%v" (int $idx) }}:
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
      pigallery:
        pigallery:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
