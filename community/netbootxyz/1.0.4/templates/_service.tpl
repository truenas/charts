{{- define "netboot.service" -}}
service:
  netboot:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: netboot
    ports:
      tftp:
        enabled: true
        primary: true
        port: {{ .Values.netbootNetwork.tftpPort }}
        nodePort: {{ .Values.netbootNetwork.tftpPort }}
        targetPort: 69
        protocol: udp
        targetSelector: netboot
      assets:
        enabled: true
        port: {{ .Values.netbootNetwork.webAssetsPort }}
        nodePort: {{ .Values.netbootNetwork.webAssetsPort }}
        targetSelector: netboot
  netboot-portal:
    enabled: true
    type: NodePort
    targetSelector: netboot
    ports:
      portal-http:
        enabled: true
        primary: true
        port: {{ .Values.netbootNetwork.webHttpPort }}
        nodePort: {{ .Values.netbootNetwork.webHttpPort }}
        targetSelector: netboot
{{- end -}}
