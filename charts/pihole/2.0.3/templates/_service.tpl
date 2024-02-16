{{- define "pihole.service" -}}
service:
  pihole:
    enabled: true
    primary: true
    type: ClusterIP
    targetSelector: pihole
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.piholeNetwork.webPort }}
        targetSelector: pihole
      dns-udp:
        enabled: true
        port: 53
        targetPort: 53
        protocol: udp
        targetSelector: pihole
      dns-tcp:
        enabled: true
        port: 53
        targetPort: 53
        targetSelector: pihole
      {{- if .Values.piholeNetwork.dhcpEnabled }}
      dhcp:
        enabled: true
        port: 67
        targetPort: 67
        protocol: udp
        targetSelector: pihole
      {{- end }}
{{- end -}}
