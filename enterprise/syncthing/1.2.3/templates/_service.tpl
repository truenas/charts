{{- define "syncthing.service" -}}
service:
  syncthing-web:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: syncthing
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.syncthingNetwork.webPort }}
        nodePort: {{ .Values.syncthingNetwork.webPort }}
        targetSelector: syncthing
  syncthing-discovery:
    # Only enable this service if local discovery is enabled
    enabled: {{ .Values.syncthingConfig.localDiscovery }}
    type: NodePort
    targetSelector: syncthing
    ports:
      discovery:
        enabled: true
        port: {{ .Values.syncthingNetwork.localDiscoveryPort }}
        nodePort: {{ .Values.syncthingNetwork.localDiscoveryPort }}
        targetPort: 21017
        protocol: udp
        targetSelector: syncthing
  syncthing-transfer:
    enabled: true
    type: NodePort
    targetSelector: syncthing
    ports:
      tcp:
        enabled: true
        primary: true
        port: {{ .Values.syncthingNetwork.tcpPort }}
        nodePort: {{ .Values.syncthingNetwork.tcpPort }}
        targetPort: 22000
        targetSelector: syncthing
      quic:
        enabled: true
        port: {{ .Values.syncthingNetwork.quicPort }}
        nodePort: {{ .Values.syncthingNetwork.quicPort }}
        targetPort: 22000
        protocol: udp
        targetSelector: syncthing
{{- end -}}
