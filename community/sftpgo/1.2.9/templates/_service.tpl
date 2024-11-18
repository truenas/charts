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
  {{- include "sftpgo.svc.gen" (dict "rootCtx" $ "type" "sftpd") | nindent 2 }}
  {{- include "sftpgo.svc.gen" (dict "rootCtx" $ "type" "ftpd") | nindent 2 }}
  {{- include "sftpgo.svc.gen" (dict "rootCtx" $ "type" "webdavd") | nindent 2 }}
{{- end -}}
