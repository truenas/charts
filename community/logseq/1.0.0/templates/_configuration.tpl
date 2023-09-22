{{- define "logseq.configuration" -}}
configmap:
  nginx-config:
    enabled: true
    data:
      nginx.conf: |
        server {
        {{- if .Values.logseqNetwork.certificateID }}
          listen              {{ .Values.logseqNetwork.webPort }} ssl;
          ssl_certificate     /etc/nginx/certs/tls.crt;
          ssl_certificate_key /etc/nginx/certs/tls.key;
        {{- else }}
          listen              {{ .Values.logseqNetwork.webPort }};
        {{- end }}

          error_page          500 502 503 504  /50x.html;
          location = /50x.html {
              root            /usr/share/nginx/html;
          }

          location / {
              root            /usr/share/nginx/html;
              index           index.html index.htm;
          }

          location /health {
              return          200;
          }
        }
{{- end -}}
