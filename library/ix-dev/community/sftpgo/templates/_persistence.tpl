{{- define "sftpgo.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.sftpgoStorage.config.type }}
    datasetName: {{ .Values.sftpgoStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.sftpgoStorage.config.hostPath | default "" }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /var/lib/sftpgo
        01-permissions:
          mountPath: /mnt/directories/config
  data:
    enabled: true
    type: {{ .Values.sftpgoStorage.data.type }}
    datasetName: {{ .Values.sftpgoStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.sftpgoStorage.data.hostPath | default "" }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /srv/sftpgo/data
        01-permissions:
          mountPath: /mnt/directories/data
  backups:
    enabled: true
    type: {{ .Values.sftpgoStorage.backups.type }}
    datasetName: {{ .Values.sftpgoStorage.backups.datasetName | default "" }}
    hostPath: {{ .Values.sftpgoStorage.backups.hostPath | default "" }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /srv/sftpgo/backups
        01-permissions:
          mountPath: /mnt/directories/backups
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.sftpgoStorage.additionalStorages }}
  {{ printf "sftpgo-%v" (int $idx) }}:
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
      sftpgo:
        sftpgo:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
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
