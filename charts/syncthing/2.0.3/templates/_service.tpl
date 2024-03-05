{{- define "syncthing.service" -}}
service:
  syncthing:
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
      sync-tcp:
        enabled: true
        port: {{ .Values.syncthingNetwork.tcpPort }}
        nodePort: {{ .Values.syncthingNetwork.tcpPort }}
        targetPort: 22000
        targetSelector: syncthing
      sync-udp:
        enabled: true
        port: {{ .Values.syncthingNetwork.udpPort }}
        nodePort: {{ .Values.syncthingNetwork.udpPort }}
        targetPort: 22000
        protocol: udp
        targetSelector: syncthing
{{- end -}}
