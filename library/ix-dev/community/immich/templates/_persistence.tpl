{{- define "immich.persistence" -}}
persistence:
  {{/* Data */}}
  library:
    enabled: true
    type: {{ .Values.immichStorage.library.type }}
    datasetName: {{ .Values.immichStorage.library.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.library.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/library
      microservices:
        microservices:
          mountPath: /usr/src/app/upload/library
  uploads:
    enabled: true
    type: {{ .Values.immichStorage.uploads.type }}
    datasetName: {{ .Values.immichStorage.uploads.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.uploads.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/upload
      microservices:
        microservices:
          mountPath: /usr/src/app/upload/upload
  thumbs:
    enabled: true
    type: {{ .Values.immichStorage.thumbs.type }}
    datasetName: {{ .Values.immichStorage.thumbs.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.thumbs.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/thumbs
      microservices:
        microservices:
          mountPath: /usr/src/app/upload/thumbs
  profile:
    enabled: true
    type: {{ .Values.immichStorage.profile.type }}
    datasetName: {{ .Values.immichStorage.profile.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.profile.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/profile
      microservices:
        microservices:
          mountPath: /usr/src/app/upload/profile
  video:
    enabled: true
    type: {{ .Values.immichStorage.video.type }}
    datasetName: {{ .Values.immichStorage.video.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.video.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/encoded-video
      microservices:
        microservices:
          mountPath: /usr/src/app/upload/encoded-video
  {{- range $idx, $storage := .Values.immichStorage.additionalLibraries }}
  {{ printf "immich-%v" (int $idx) }}:
    enabled: true
    type: hostPath
    hostPath: {{ $storage.hostPath | default "" }}
    # Host path and mount path MUST be the same
    targetSelector:
      server:
        server:
          mountPath: {{ $storage.hostPath }}
      microservices:
        microservices:
          mountPath: {{ $storage.hostPath }}
  {{- end }}
  {{/* Caches */}}
  microcache:
    enabled: true
    type: emptyDir
    targetSelector:
      microservices:
        microservices:
          mountPath: /microcache
  {{- if .Values.immichConfig.enableTypesense }}
  typsense:
    enabled: true
    type: emptyDir
    targetSelector:
      typesense:
        typesense:
          mountPath: /typesense-data
  {{- end -}}
  {{- if .Values.immichConfig.enableML }}
  mlcache:
    enabled: true
    type: emptyDir
    targetSelector:
      machinelearning:
        machinelearning:
          mountPath: /mlcache
  {{- end }}
  redis:
    enabled: true
    type: emptyDir
    targetSelector:
      redis:
        redis:
          mountPath: /bitnami/redis/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      redis:
        redis:
          mountPath: /tmp

  {{/* Database */}}
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.immichStorage.pgData
            "pgBackup" .Values.immichStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
