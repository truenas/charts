{{- define "deluge.service" -}}
service:
  deluge:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: deluge
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.delugeNetwork.webPort }}
        nodePort: {{ .Values.delugeNetwork.webPort }}
        targetPort: 8112
        targetSelector: deluge
      {{- if .Values.delugeNetwork.exposeDaemon }}
      daemon:
        enabled: true
        port: {{ .Values.delugeNetwork.daemonPort }}
        nodePort: {{ .Values.delugeNetwork.daemonPort }}
        targetPort: 58846
        targetSelector: deluge
      {{- end }}
  torrent:
    enabled: true
    type: NodePort
    targetSelector: deluge
    ports:
      tcp:
        enabled: true
        primary: true
        port: {{ .Values.delugeNetwork.torrentPort }}
        nodePort: {{ .Values.delugeNetwork.torrentPort }}
        targetSelector: deluge
      udp:
        enabled: true
        port: {{ .Values.delugeNetwork.torrentPort }}
        nodePort: {{ .Values.delugeNetwork.torrentPort }}
        protocol: udp
        targetSelector: deluge
{{- end -}}
