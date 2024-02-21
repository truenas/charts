{{- define "syncthing.service" -}}
service:
  syncthing:
    enabled: true
    primary: true
    type: ClusterIP
    targetSelector: syncthing
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.syncthingNetwork.webPort }}
        targetSelector: syncthing
      sync-tcp:
        enabled: true
        port: {{ .Values.syncthingNetwork.tcpPort }}
        targetPort: 22000
        targetSelector: syncthing
      sync-udp:
        enabled: true
        port: {{ .Values.syncthingNetwork.udpPort }}
        targetPort: 22000
        protocol: udp
        targetSelector: syncthing
{{- end -}}
