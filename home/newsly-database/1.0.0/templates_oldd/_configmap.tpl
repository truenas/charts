{{- define "newsly.config" -}}

apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  config.json: |
    {
      "news_database": {
        "username": "{{ .Values.newslyDatabase.username }}",
        "password": "{{ .Values.newslyDatabase.password }}",
        "ip_address": "{{ .Values.newslyDatabase.host }}",
        "port": "{{ .Values.newslyDatabase.port }}",
        "dbname": "{{ .Values.newslyDatabase.dbname }}"
      }
    }
{{- end -}}
