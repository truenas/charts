{{- define "sftpgo.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.sftpgoStorage.config.type }}
    datasetName: {{ .Values.sftpgoStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.sftpgoStorage.config.hostPath | default "" }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.sftpgoStorage.config) | nindent 4 }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /var/lib/sftpgo
        {{- if and (eq .Values.sftpgoStorage.config.type "ixVolume")
                  (not (.Values.sftpgoStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.sftpgoStorage.data) | nindent 4 }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /srv/sftpgo/data
        {{- if and (eq .Values.sftpgoStorage.data.type "ixVolume")
                  (not (.Values.sftpgoStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  backups:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.sftpgoStorage.backups) | nindent 4 }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /srv/sftpgo/backups
        {{- if and (eq .Values.sftpgoStorage.backups.type "ixVolume")
                  (not (.Values.sftpgoStorage.backups.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/backups
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.sftpgoStorage.additionalStorages }}
  {{ printf "sftpgo-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end -}}
  {{- if .Values.sftpgoNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: sftpgo-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: private.key
      - key: tls.crt
        path: public.crt
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /srv/sftpgo/certs
          readOnly: true

scaleCertificate:
  sftpgo-cert:
    enabled: true
    id: {{ .Values.sftpgoNetwork.certificateID }}
    {{- end -}}
{{- end -}}
