{{- define "newslydb.service" -}}
service:
    newsly-db:
        enabled: true
        primary: true
        type: NodePort
        targetSelector: newsly-db
        ports:
        webui:
            enabled: true
            primary: true
            port: 5432
            nodePort: {{ .Values.newslyDatabase.port }}
            targetSelector: newsly-db
    
    {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}