{{- define "passbolt.persistence" -}}
persistence:
  gpg:
    enabled: true
    type: {{ .Values.passboltStorage.gpg.type }}
    datasetName: {{ .Values.passboltStorage.gpg.datasetName | default "" }}
    hostPath: {{ .Values.passboltStorage.gpg.hostPath | default "" }}
    targetSelector:
      passbolt:
        passbolt:
          mountPath: /etc/passbolt/gpg
  jwt:
    enabled: true
    type: {{ .Values.passboltStorage.jwt.type }}
    datasetName: {{ .Values.passboltStorage.jwt.datasetName | default "" }}
    hostPath: {{ .Values.passboltStorage.jwt.hostPath | default "" }}
    targetSelector:
      passbolt:
        passbolt:
          mountPath: /etc/passbolt/jwt
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      passbolt:
        passbolt:
          mountPath: /tmp
  varrun:
    enabled: true
    type: emptyDir
    targetSelector:
      passbolt:
        passbolt:
          mountPath: /var/run
  {{- range $idx, $storage := .Values.passboltStorage.additionalStorages }}
  {{ printf "passbolt-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      passbolt:
        passbolt:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}

  mariadbdata:
    enabled: true
    type: {{ .Values.passboltStorage.mariadbData.type }}
    datasetName: {{ .Values.passboltStorage.mariadbData.datasetName | default "" }}
    hostPath: {{ .Values.passboltStorage.mariadbData.hostPath | default "" }}
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
    type: {{ .Values.passboltStorage.mariadbBackup.type }}
    datasetName: {{ .Values.passboltStorage.mariadbBackup.datasetName | default "" }}
    hostPath: {{ .Values.passboltStorage.mariadbBackup.hostPath | default "" }}
    targetSelector:
      # MariaDB backup pod
      mariadbbackup:
        # MariaDB backup container
        mariadbbackup:
          mountPath: /mariadb_backup
        # MariaDB - Permissions container
        permissions:
          mountPath: /mnt/directories/mariadb_backup

  {{- if .Values.passboltNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: passbolt-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: certificate.key
      - key: tls.crt
        path: certificate.crt
    targetSelector:
      passbolt:
        passbolt:
          mountPath: /etc/passbolt/certs
          readOnly: true

scaleCertificate:
  passbolt-cert:
    enabled: true
    id: {{ .Values.passboltNetwork.certificateID }}
    {{- end -}}
{{- end -}}
