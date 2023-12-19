{{- define "castopod.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "castopod.storage.ci.migration" (dict "storage" .Values.castopodStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.castopodStorage.data) | nindent 4 }}
    targetSelector:
      castopod:
        castopod:
          mountPath: /var/www/castopod/public/media
      web:
        web:
          mountPath: /var/www/html/media
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      castopod:
        castopod:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.castopodStorage.additionalStorages }}
  {{ printf "castopod-%v" (int $idx) }}:
    enabled: true
    {{- include "castopod.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      castopod:
        castopod:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  mariadbdata:
    enabled: true
    {{- include "castopod.storage.ci.migration" (dict "storage" .Values.castopodStorage.mariadbData) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.castopodStorage.mariadbData) | nindent 4 }}
    targetSelector:
      # MariaDB pod
      mariadb:
        # MariaDB container
        mariadb:
          mountPath: /var/lib/mysql
        # MariaDB - Permissions container
        permissions:
          mountPath: /mnt/directories/mariadb_data
  mariadbbackup:
    enabled: true
    {{- include "castopod.storage.ci.migration" (dict "storage" .Values.castopodStorage.mariadbBackup) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.castopodStorage.mariadbBackup) | nindent 4 }}
    targetSelector:
      # MariaDB backup pod
      mariadbbackup:
        # MariaDB backup container
        mariadbbackup:
          mountPath: /mariadb_backup
        # MariaDB - Permissions container
        permissions:
          mountPath: /mnt/directories/mariadb_backup
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "castopod.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
