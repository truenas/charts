{{- define "nextcloud.service" -}}
service:
  nextcloud:
    enabled: true
    primary: true
    {{- if not .Values.ncNetwork.certificateID }}
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
        {{- end }}
        port: 80
        targetPort: 80
        targetSelector: nextcloud
  {{- if .Values.ncNetwork.certificateID }}
  nextcloud-nginx:
    enabled: true
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

  # Redis
  redis:
    enabled: true
    type: ClusterIP
    targetSelector: redis
    ports:
      redis:
        enabled: true
        primary: true
        port: 6379
        targetPort: 6379
        targetSelector: redis
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}
{{- end -}}
