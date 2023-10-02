{{- define "castopod.service" -}}
service:
  castopod:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: castopod
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.castopodNetwork.webPort }}
        nodePort: {{ .Values.castopodNetwork.webPort }}
        targetPort: 8000
        targetSelector: castopod
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
  redis:
    enabled: true
    type: ClusterIP
    targetSelector: redis
    ports:
      redis:
        enabled: true
        primary: true
        port: 6379
        targetPort: 6379
        targetSelector: redis
{{- end -}}
