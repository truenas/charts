{{- define "rust.service" -}}
# https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/
service:
  server1:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: server
    ports:
      nat-type-test:
        enabled: true
        primary: true
        port: {{ .Values.rustNetwork.natTypeTestPort }}
        nodePort: {{ .Values.rustNetwork.natTypeTestPort }}
        targetPort: 21115
        targetSelector: server
      web-clients:
        enabled: {{ .Values.rustNetwork.enableWebClientPorts }}
        port: {{ .Values.rustNetwork.serverWebClientsPort }}
        nodePort: {{ .Values.rustNetwork.serverWebClientsPort }}
        targetPort: 21118
        targetSelector: server
  server2:
    enabled: true
    type: NodePort
    targetSelector: server
    ports:
      tcp-hole-punch:
        enabled: true
        port: {{ .Values.rustNetwork.idRegHolePunchPort }}
        nodePort: {{ .Values.rustNetwork.idRegHolePunchPort }}
        targetPort: 21116
        targetSelector: server
      id-registration:
        enabled: true
        port: {{ .Values.rustNetwork.idRegHolePunchPort }}
        nodePort: {{ .Values.rustNetwork.idRegHolePunchPort }}
        targetPort: 21116
        protocol: udp
        targetSelector: server
  relay:
    enabled: true
    type: NodePort
    targetSelector: relay
    ports:
      relay:
        enabled: true
        primary: true
        port: {{ .Values.rustNetwork.relayPort }}
        nodePort: {{ .Values.rustNetwork.relayPort }}
        targetPort: 21117
        targetSelector: relay
      web-clients:
        enabled: {{ .Values.rustNetwork.enableWebClientPorts }}
        port: {{ .Values.rustNetwork.relayWebClientsPort }}
        nodePort: {{ .Values.rustNetwork.relayWebClientsPort }}
        targetPort: 21119
        targetSelector: relay
{{- end -}}
