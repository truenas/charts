{{- define "immich.persistence" -}}
  {{- include "immich.storage.ci.migration" (dict "storage" .Values.immichStorage.pgData) }}
  {{- include "immich.storage.ci.migration" (dict "storage" .Values.immichStorage.pgBackup) }}
  {{- include "immich.storage.ci.migration" (dict "storage" .Values.immichStorage.library) }}
  {{- include "immich.storage.ci.migration" (dict "storage" .Values.immichStorage.uploads) }}
  {{- include "immich.storage.ci.migration" (dict "storage" .Values.immichStorage.thumbs) }}
  {{- include "immich.storage.ci.migration" (dict "storage" .Values.immichStorage.profile) }}
  {{- include "immich.storage.ci.migration" (dict "storage" .Values.immichStorage.video) }}

persistence:
  {{/* Data */}}
  library:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.immichStorage.library) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/library
      microservices:
        microservices:
          mountPath: /usr/src/app/upload/library
  uploads:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.immichStorage.uploads) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/upload
      microservices:
        microservices:
          mountPath: /usr/src/app/upload/upload
  thumbs:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.immichStorage.thumbs) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/thumbs
      microservices:
        microservices:
          mountPath: /usr/src/app/upload/thumbs
  profile:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.immichStorage.profile) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/profile
      microservices:
        microservices:
          mountPath: /usr/src/app/upload/profile
  video:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.immichStorage.video) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/encoded-video
      microservices:
        microservices:
          mountPath: /usr/src/app/upload/encoded-video
  {{- range $idx, $storage := .Values.immichStorage.additionalStorages }}
  {{ printf "immich-%v:" (int $idx) }}
    enabled: true
    {{- include "immich.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: {{ $storage.mountPath }}
      microservices:
        microservices:
          mountPath: {{ $storage.mountPath }}
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

{{/* Can be removed on the next bump (1.1.0+), only used for CI values */}}
{{- define "immich.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
