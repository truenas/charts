{{- define "storj.service" -}}
service:
  storj:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: storj
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.storjNetwork.webPort }}
        nodePort: {{ .Values.storjNetwork.webPort }}
        targetPort: 14002
        targetSelector: storj
      p2p-tcp:
        enabled: true
        port: {{ .Values.storjNetwork.p2pPort }}
        nodePort: {{ .Values.storjNetwork.p2pPort }}
        targetPort: 28967
        targetSelector: storj
      p2p-udp:
        enabled: true
        port: {{ .Values.storjNetwork.p2pPort }}
        nodePort: {{ .Values.storjNetwork.p2pPort }}
        targetPort: 28967
        protocol: udp
        targetSelector: storj
{{- end -}}
