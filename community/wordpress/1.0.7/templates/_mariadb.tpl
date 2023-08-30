{{- define "wordpress.mariadb.workload" -}}
workload:
{{- include "ix.v1.common.app.mariadb" (dict "secretName" "mariadb-creds"
                                              "resources" .Values.resources
                                              "ixChartContext" .Values.ixChartContext) | nindent 2 }}
{{/* Service */}}
service:
  mariadb:
    enabled: true
    type: ClusterIP
    targetSelector: mariadb
    ports:
      mariadb:
        enabled: true
        primary: true
        port: 3306
        targetPort: 3306
        targetSelector: mariadb

{{/* Persistence */}}
persistence:
  mariadbdata:
    enabled: true
    type: {{ .Values.wpStorage.mariadbData.type }}
    datasetName: {{ .Values.wpStorage.mariadbData.datasetName | default "" }}
    hostPath: {{ .Values.wpStorage.mariadbData.hostPath | default "" }}
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
    type: {{ .Values.wpStorage.mariadbBackup.type }}
    datasetName: {{ .Values.wpStorage.mariadbBackup.datasetName | default "" }}
    hostPath: {{ .Values.wpStorage.mariadbBackup.hostPath | default "" }}
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
