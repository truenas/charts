{{- define "collabora.service" -}}
{{- $cert := ne (toString .Values.collaboraNetwork.certificateID) "" }}
service:
  collabora:
    enabled: true
    primary: true
    type: {{ ternary "ClusterIP" "NodePort" $cert }}
    targetSelector: collabora
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ ternary 9980 .Values.collaboraNetwork.webPort $cert }}
        {{- if not .Values.collaboraNetwork.certificateID }}
        nodePort: {{ .Values.collaboraNetwork.webPort }}
        {{- end }}
        targetPort: 9980
        targetSelector: collabora
  {{- if .Values.collaboraNetwork.certificateID }}
  nginx:
    enabled: true
    type: NodePort
    targetSelector: nginx
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.collaboraNetwork.webPort }}
        nodePort: {{ .Values.collaboraNetwork.webPort }}
        targetPort: 443
        targetSelector: nginx
  {{- end -}}
{{- end -}}
