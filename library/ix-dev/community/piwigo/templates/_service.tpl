{{- define "piwigo.service" -}}
service:
  piwigo:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: piwigo
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.piwiNetwork.webPort }}
        nodePort: {{ .Values.piwiNetwork.webPort }}
        targetPort: 80
        targetSelector: piwigo
  mariadb:
    enabled: true
    type: ClusterIP
    targetSelector: mariadb
    ports:
      mariadb:
        enabled: true
        primary: true
        port: 3306
        targetPort: 3306
        targetSelector: mariadb
{{- end -}}
