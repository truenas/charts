{{- define "immich.service" -}}
service:
  server:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: server
    ports:
      server:
        enabled: true
        primary: true
        port: {{ .Values.immichNetwork.webuiPort }}
        nodePort: {{ .Values.immichNetwork.webuiPort }}
        protocol: http
        targetSelector: server

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

  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
