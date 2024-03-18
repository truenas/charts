{{- define "plex.service" -}}
service:
  plex:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: plex
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.plexNetwork.webPort }}
        nodePort: {{ .Values.plexNetwork.webPort }}
        targetPort: 32400
        targetSelector: plex
  discovery:
    enabled: true
    # This service is added only to provide
    # a way for in-cluster apps to discovery plex
    # For LAN discovery, host networking is required
    type: ClusterIP
    targetSelector: plex
    ports:
      dlna-tcp:
        enabled: true
        primary: true
        port: 32469
        targetPort: 32469
        protocol: tcp
        targetSelector: plex
      dlna-udp:
        enabled: true
        port: 1900
        targetPort: 1900
        protocol: udp
        targetSelector: plex
      gdm1:
        enabled: true
        port: 32410
        targetPort: 32410
        protocol: udp
        targetSelector: plex
      gdm2:
        enabled: true
        port: 32412
        targetPort: 32412
        protocol: udp
        targetSelector: plex
      gdm3:
        enabled: true
        port: 32413
        targetPort: 32413
        protocol: udp
        targetSelector: plex
      gdm4:
        enabled: true
        port: 32414
        targetPort: 32414
        protocol: udp
        targetSelector: plex
{{- end -}}
