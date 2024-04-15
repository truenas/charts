{{- define "wgeasy.service" -}}
service:
  wgeasy:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: wgeasy
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.wgNetwork.webPort }}
        nodePort: {{ .Values.wgNetwork.webPort }}
        targetSelector: wgeasy
      vpn:
        enabled: true
        port: {{ .Values.wgNetwork.udpPort }}
        nodePort: {{ .Values.wgNetwork.udpPort }}
        targetPort: 51820
        protocol: udp
        targetSelector: wgeasy
{{- end -}}
