{{- define "pigallery.configuration" -}}
configmap:
  pigallery-config:
    enabled: true
    data:
      # While its marked as temporary folder, it is not to be thrown away.
      # It stores the thumbnails and other generated files.
      Media-tempFolder: /app/data/thumbnails
      Media-folder: /app/data/media
      Database-sqlite-DBFileName: sqlite.db
      Database-dbFolder: /app/data/db
      Database-type: sqlite
      Server-applicationTitle: {{ .Values.pigalleryConfig.applicationTitle | quote }}
      Server-port: {{ .Values.pigalleryNetwork.webPort | quote }}
      PORT: {{ .Values.pigalleryNetwork.webPort | quote }}
      PI_DOCKER: "true"
      NODE_ENV: production
{{- end -}}
