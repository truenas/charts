{{- define "palworld.service" -}}
service:
  palworld:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: palworld
    ports:
      server:
        enabled: true
        primary: true
        port: {{ .Values.palworldNetwork.serverPort }}
        nodePort: {{ .Values.palworldNetwork.serverPort }}
        protocol: udp
        targetSelector: palworld
{{- end -}}
