{{- define "piwigo.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "piwi.storage.ci.migration" (dict "storage" .Values.piwiStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.piwiStorage.config) | nindent 4 }}
    targetSelector:
      piwigo:
        piwigo:
          mountPath: /config
  gallery:
    enabled: true
    {{- include "piwi.storage.ci.migration" (dict "storage" .Values.piwiStorage.gallery) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.piwiStorage.gallery) | nindent 4 }}
    targetSelector:
      piwigo:
        piwigo:
          mountPath: /gallery
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      piwigo:
        piwigo:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.piwiStorage.additionalStorages }}
  {{ printf "piwi-%v" (int $idx) }}:
    enabled: true
    {{- include "piwi.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      piwigo:
        piwigo:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  mariadbdata:
    enabled: true
    {{- include "piwi.storage.ci.migration" (dict "storage" .Values.piwiStorage.mariadbData) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.piwiStorage.mariadbData) | nindent 4 }}
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
    {{- include "piwi.storage.ci.migration" (dict "storage" .Values.piwiStorage.mariadbBackup) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.piwiStorage.mariadbBackup) | nindent 4 }}
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
{{- define "piwi.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
