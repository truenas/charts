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
        targetPort: 8211
        protocol: udp
        targetSelector: palworld
{{- end -}}
