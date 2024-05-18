{{- define "emby.service" -}}
service:
  emby:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: emby
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.embyNetwork.webPort }}
        nodePort: {{ .Values.embyNetwork.webPort }}
        targetPort: 8096
        targetSelector: emby
  discovery:
    enabled: true
    # This service is added only to provide
    # a way for in-cluster apps to discovery emby
    # For LAN discovery, host networking is required
    type: ClusterIP
    targetSelector: emby
    ports:
      dlna:
        enabled: true
        primary: true
        port: 1900
        targetPort: 1900
        protocol: udp
        targetSelector: emby
      local-discovery:
        enabled: true
        port: 7359
        targetPort: 7359
        protocol: udp
        targetSelector: emby
{{- end -}}
