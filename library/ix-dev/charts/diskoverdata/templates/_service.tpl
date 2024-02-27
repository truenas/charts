{{- define "diskover.service" -}}
service:
  diskover:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: diskover
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.diskoverNetwork.webPort }}
        nodePort: {{ .Values.diskoverNetwork.webPort }}
        targetPort: 80
        targetSelector: diskover
  elasticsearch:
    enabled: true
    type: ClusterIP
    targetSelector: elasticsearch
    ports:
      elasticsearch:
        enabled: true
        primary: true
        port: 9200
        targetPort: 9200
        targetSelector: elasticsearch
{{- end -}}
