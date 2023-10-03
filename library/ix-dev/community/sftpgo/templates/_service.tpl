{{- define "sftpgo.service" -}}
service:
  sftpgo:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: sftpgo
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.sftpgoNetwork.webPort }}
        nodePort: {{ .Values.sftpgoNetwork.webPort }}
        targetSelector: sftpgo
  {{- if .Values.sftpgoNetwork.sfptdEnabled }}
  sftpgo-sftp:
    enabled: true
    type: NodePort
    targetSelector: sftpgo
    ports:
      sftp:
        enabled: true
        primary: true
        port: {{ .Values.sftpgoNetwork.sftpdPort }}
        nodePort: {{ .Values.sftpgoNetwork.sftpdPort }}
        targetSelector: sftpgo
  {{- end -}}
  {{- if .Values.sftpgoNetwork.ftpdEnabled }}
  sftpgo-ftp:
    enabled: true
    type: NodePort
    targetSelector: sftpgo
    ports:
      ftp:
        enabled: true
        primary: true
        port: {{ .Values.sftpgoNetwork.ftpdPort }}
        nodePort: {{ .Values.sftpgoNetwork.ftpdPort }}
        targetSelector: sftpgo
  {{- end -}}
  {{- if .Values.sftpgoNetwork.webdavEnabled }}
  sftpgo-webdav:
    enabled: true
    type: NodePort
    targetSelector: sftpgo
    ports:
      webdav:
        enabled: true
        primary: true
        port: {{ .Values.sftpgoNetwork.webdavPort }}
        nodePort: {{ .Values.sftpgoNetwork.webdavPort }}
        targetSelector: sftpgo
  {{- end -}}
{{- end -}}
