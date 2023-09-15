{{- define "unifi.service" -}}
service:
  unifi:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: unifi
    ports:
      https:
        enabled: true
        primary: true
        port: {{ .Values.unifiNetwork.webHttpsPort }}
        nodePort: {{ .Values.unifiNetwork.webHttpsPort }}
        targetSelector: unifi
      http:
        enabled: {{ .Values.unifiNetwork.enableWebHttp }}
        port: {{ .Values.unifiNetwork.webHttpPort }}
        nodePort: {{ .Values.unifiNetwork.webHttpPort }}
        targetSelector: unifi
  unifi-portal:
    enabled: true
    type: NodePort
    targetSelector: unifi
    ports:
      https:
        enabled: true
        primary: true
        port: {{ .Values.unifiNetwork.portalHttpsPort }}
        nodePort: {{ .Values.unifiNetwork.portalHttpsPort }}
        targetSelector: unifi
      http:
        enabled: {{ .Values.unifiNetwork.enablePortalHttp }}
        port: {{ .Values.unifiNetwork.portalHttpPort }}
        nodePort: {{ .Values.unifiNetwork.portalHttpPort }}
        targetSelector: unifi
{{- end -}}
