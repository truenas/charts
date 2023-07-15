{{- define "immich.service" -}}
service:
  proxy:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: proxy
    ports:
      proxy:
        enabled: true
        primary: true
        port: {{ .Values.immichNetwork.webuiPort }}
        nodePort: {{ .Values.immichNetwork.webuiPort }}
        protocol: http
        targetPort: 8080
        targetSelector: proxy

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

  microservices:
    enabled: true
    type: ClusterIP
    targetSelector: microservices
    ports:
      microservices:
        enabled: true
        primary: true
        port: {{ .Values.immichNetwork.microservicesPort }}
        protocol: http
        targetSelector: microservices

  {{- if .Values.immichConfig.enableML }}
  machinelearning:
    enabled: true
    type: ClusterIP
    targetSelector: machinelearning
    ports:
      machinelearning:
        enabled: true
        primary: true
        port: {{ .Values.immichNetwork.machinelearningPort }}
        protocol: http
        targetSelector: machinelearning
  {{- end -}}

  {{- if .Values.immichConfig.enableTypesense }}
  typesense:
    enabled: true
    type: ClusterIP
    targetSelector: typesense
    ports:
      typesense:
        enabled: true
        primary: true
        port: {{ .Values.immichNetwork.typesensePort }}
        protocol: http
        targetSelector: typesense
  {{- end }}

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

  postgres:
    enabled: true
    type: ClusterIP
    targetSelector: postgres
    ports:
      postgres:
        enabled: true
        primary: true
        port: 5432
        targetPort: 5432
        targetSelector: postgres
{{- end -}}
