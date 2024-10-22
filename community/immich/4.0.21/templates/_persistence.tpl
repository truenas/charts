{{- define "immich.persistence" -}}
persistence:
  {{/* Data */}}
  library:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.immichStorage.library) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/library
  uploads:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.immichStorage.uploads) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/upload
  thumbs:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.immichStorage.thumbs) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/thumbs
  profile:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.immichStorage.profile) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/profile
  video:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.immichStorage.video) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/encoded-video
  {{- range $idx, $storage := .Values.immichStorage.additionalStorages }}
  {{ printf "immich-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
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
