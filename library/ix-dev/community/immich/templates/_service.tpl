{{- define "immich.service" -}}
service:
  proxy:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: web
    # FIXME: targetSelector: proxy
    ports:
      proxy:
        enabled: true
        primary: true
        port: {{ .Values.immichNetwork.webPort }}
        nodePort: {{ .Values.immichNetwork.webPort }}
        protocol: http
        targetPort: 8080
        # FIXME: targetSelector: proxy
        targetSelector: web

  server:
    enabled: true
    type: ClusterIP
    targetSelector: server
    ports:
      server:
        enabled: true
        primary: true
        port: {{ .Values.immichNetwork.serverPort }}
        protocol: http
        targetSelector: server

  web:
    enabled: true
    type: ClusterIP
    targetSelector: web
    ports:
      web:
        enabled: true
        primary: true
        port: {{ .Values.immichNetwork.webPort }}
        protocol: http
        targetSelector: web

  postgres:
    enabled: true
    type: ClusterIP
    targetSelector: postgres
    ports:
      postgres:
        enabled: true
        primary: true
        port: 5432
        targetSelector: postgres
{{- end -}}
