{{- define "transmission.service" -}}
service:
  transmission:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: transmission
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.transmissionNetwork.webPort }}
        nodePort: {{ .Values.transmissionNetwork.webPort }}
        targetSelector: transmission
  transmission-peer:
    enabled: true
    type: NodePort
    targetSelector: transmission
    ports:
      tcp:
        enabled: true
        primary: true
        port: {{ .Values.transmissionNetwork.peerPort }}
        nodePort: {{ .Values.transmissionNetwork.peerPort }}
        targetSelector: transmission
      udp:
        enabled: true
        port: {{ .Values.transmissionNetwork.peerPort }}
        nodePort: {{ .Values.transmissionNetwork.peerPort }}
        protocol: udp
        targetSelector: transmission
{{- end -}}
