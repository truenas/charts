{{- define "piwigo.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.piwiStorage.config.type }}
    datasetName: {{ .Values.piwiStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.piwiStorage.config.hostPath | default "" }}
    targetSelector:
      piwigo:
        piwigo:
          mountPath: /config
  gallery:
    enabled: true
    type: {{ .Values.piwiStorage.gallery.type }}
    datasetName: {{ .Values.piwiStorage.gallery.datasetName | default "" }}
    hostPath: {{ .Values.piwiStorage.gallery.hostPath | default "" }}
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
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      piwigo:
        piwigo:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  mariadbdata:
    enabled: true
    type: {{ .Values.piwiStorage.mariadbData.type }}
    datasetName: {{ .Values.piwiStorage.mariadbData.datasetName | default "" }}
    hostPath: {{ .Values.piwiStorage.mariadbData.hostPath | default "" }}
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
    type: {{ .Values.piwiStorage.mariadbBackup.type }}
    datasetName: {{ .Values.piwiStorage.mariadbBackup.datasetName | default "" }}
    hostPath: {{ .Values.piwiStorage.mariadbBackup.hostPath | default "" }}
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
