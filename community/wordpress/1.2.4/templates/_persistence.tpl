{{- define "wordpress.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "wp.storage.ci.migration" (dict "storage" .Values.wpStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.wpStorage.data) | nindent 4 }}
    targetSelector:
      wordpress:
        wordpress:
          mountPath: /var/www/html
        {{- if and (eq .Values.wpStorage.data.type "ixVolume")
                  (not (.Values.wpStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
      wordpress-cron:
        wordpress-cron:
          mountPath: /var/www/html
  {{- range $idx, $storage := .Values.wpStorage.additionalStorages }}
  {{ printf "wp-%v" (int $idx) }}:
    enabled: true
    {{- include "wp.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      wordpress:
        wordpress:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      wordpress:
        wordpress:
          mountPath: /tmp
  varrun:
    enabled: true
    type: emptyDir
    targetSelector:
      wordpress:
        wordpress:
          mountPath: /var/run
  mariadbdata:
    enabled: true
    {{- include "wp.storage.ci.migration" (dict "storage" .Values.wpStorage.mariadbData) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.wpStorage.mariadbData) | nindent 4 }}
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
    {{- include "wp.storage.ci.migration" (dict "storage" .Values.wpStorage.mariadbBackup) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.wpStorage.mariadbBackup) | nindent 4 }}
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
{{- define "wp.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
