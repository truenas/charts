{{- define "passbolt.persistence" -}}
persistence:
  gpg:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.passboltStorage.gpg) | nindent 4 }}
    targetSelector:
      passbolt:
        passbolt:
          mountPath: /etc/passbolt/gpg
        {{- if and (eq .Values.passboltStorage.gpg.type "ixVolume")
                  (not (.Values.passboltStorage.gpg.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/gpg
        {{- end }}
  jwt:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.passboltStorage.jwt) | nindent 4 }}
    targetSelector:
      passbolt:
        passbolt:
          mountPath: /etc/passbolt/jwt
        {{- if and (eq .Values.passboltStorage.jwt.type "ixVolume")
                  (not (.Values.passboltStorage.jwt.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/jwt
        {{- end }}
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
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      passbolt:
        passbolt:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  mariadbdata:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.passboltStorage.mariadbData) | nindent 4 }}
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
    {{/* Remove on the next version (eg 1.2.0+) */}}
    {{- if eq .Values.passboltStorage.mariadbBackup.type "emptyDir" }}
      {{- $_ := set .Values.passboltStorage.mariadbBackup "emptyDirConfig" (dict "medium" "" "size" "") }}
    {{- end }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.passboltStorage.mariadbBackup) | nindent 4 }}
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
