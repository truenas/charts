{{- define "nextcloud.service" -}}
service:
  nextcloud:
    enabled: true
    primary: true
    {{- if not .Values.ncNetwork.certificateID -}}
    type: NodePort
    {{- else }}
    type: ClusterIP
    {{- end }}
    targetSelector: nextcloud
    ports:
      webui:
        enabled: true
        primary: true
        {{- if not .Values.ncNetwork.certificateID }}
        nodePort: {{ .Values.ncNetwork.webPort }}
        port: {{ .Values.ncNetwork.webPort }}
        {{- else -}}
        port: 80
        {{- end }}
        targetPort: 80
        targetSelector: nextcloud
  {{- if .Values.ncNetwork.certificateID -}}
  nextcloud-nginx:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: nginx
    ports:
      webui-tls:
        enabled: true
        port: {{ .Values.ncNetwork.webPort }}
        nodePort: {{ .Values.ncNetwork.webPort }}
        targetPort: {{ .Values.ncNetwork.webPort }}
        targetSelector: nginx
  {{- end }}

  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}
{{- end -}}
