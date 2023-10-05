{{- define "castopod.service" -}}
service:
  castopod-web:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: web
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.castopodNetwork.webPort }}
        nodePort: {{ .Values.castopodNetwork.webPort }}
        targetPort: 80
        targetSelector: web
  castopod-api:
    enabled: true
    type: ClusterIP
    targetSelector: castopod
    ports:
      api:
        enabled: true
        primary: true
        port: 9000
        targetPort: 9000
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
