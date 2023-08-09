{{- define "frigate.service" -}}
service:
  frigate:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: frigate
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.frigateNetwork.webPort }}
        nodePort: {{ .Values.frigateNetwork.webPort }}
        targetPort: 5000
        targetSelector: frigate
  {{ if .Values.frigateNetwork.enableRtmp }}
  rtmp:
    enabled: true
    type: NodePort
    targetSelector: frigate
    ports:
      rtmp:
        enabled: true
        primary: true
        port: {{ .Values.frigateNetwork.rtmpPort }}
        nodePort: {{ .Values.frigateNetwork.rtmpPort }}
        targetPort: 1935
        targetSelector: frigate
  {{ end }}
  {{ if .Values.frigateNetwork.enableRtsp }}
  rtsp:
    enabled: true
    type: NodePort
    targetSelector: frigate
    ports:
      rtsp:
        enabled: true
        primary: true
        port: {{ .Values.frigateNetwork.rtspPort }}
        nodePort: {{ .Values.frigateNetwork.rtspPort }}
        targetPort: 8554
        targetSelector: frigate
  {{ end }}
  {{ if .Values.frigateNetwork.enableWebRtc }}
  webrtc:
    enabled: true
    type: NodePort
    targetSelector: frigate
    ports:
      tcp:
        enabled: true
        primary: true
        port: {{ .Values.frigateNetwork.webRtcPort }}
        nodePort: {{ .Values.frigateNetwork.webRtcPort }}
        targetPort: 8555
        targetSelector: frigate
      udp:
        enabled: true
        port: {{ .Values.frigateNetwork.webRtcPort }}
        nodePort: {{ .Values.frigateNetwork.webRtcPort }}
        targetPort: 8555
        protocol: udp
        targetSelector: frigate
  {{ end }}
{{- end -}}
