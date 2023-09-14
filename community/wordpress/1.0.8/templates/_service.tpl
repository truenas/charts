{{- define "wordpress.service" -}}
service:
  wordpress:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: wordpress
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.wpNetwork.webPort }}
        nodePort: {{ .Values.wpNetwork.webPort }}
        targetPort: 80
        targetSelector: wordpress
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
