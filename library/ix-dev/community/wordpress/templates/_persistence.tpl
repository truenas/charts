{{- define "wordpress.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.wpStorage.data.type }}
    datasetName: {{ .Values.wpStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.wpStorage.data.hostPath | default "" }}
    targetSelector:
      wordpress:
        wordpress:
          mountPath: /var/www/html
        01-permissions:
          mountPath: /mnt/directories/data
      wordpress-cron:
        wordpress-cron:
          mountPath: /var/www/html
  {{- range $idx, $storage := .Values.wpStorage.additionalStorages }}
  {{ printf "wp-%v" (int $idx) }}:
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
      wordpress:
        wordpress:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
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
