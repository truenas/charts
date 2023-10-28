{{- define "castopod.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.castopodStorage.data.type }}
    datasetName: {{ .Values.castopodStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.castopodStorage.data.hostPath | default "" }}
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
      castopod:
        castopod:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  mariadbdata:
    enabled: true
    type: {{ .Values.castopodStorage.mariadbData.type }}
    datasetName: {{ .Values.castopodStorage.mariadbData.datasetName | default "" }}
    hostPath: {{ .Values.castopodStorage.mariadbData.hostPath | default "" }}
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
    type: {{ .Values.castopodStorage.mariadbBackup.type }}
    datasetName: {{ .Values.castopodStorage.mariadbBackup.datasetName | default "" }}
    hostPath: {{ .Values.castopodStorage.mariadbBackup.hostPath | default "" }}
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
