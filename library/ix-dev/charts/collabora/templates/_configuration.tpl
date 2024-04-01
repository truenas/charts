{{- define "collabora.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}
  {{- $nginx := printf "https://%s-nginx:%v" $fullname .Values.collaboraNetwork.webPort -}}

  {{- if .Values.collaboraNetwork.certificateID }}
configmap:
  nginx-conf:
    enabled: true
    data:
      nginx.conf: |
        events {
            worker_connections  1024;
        }
        http {
            include       mime.types;
            default_type  application/octet-stream;
            # Types to enable gzip compression on
            gzip_types
                text/plain
                text/css
                text/js
                text/xml
                text/javascript
                application/javascript
                application/x-javascript
                application/json
                application/xml
                application/rss+xml
                image/svg+xml;
            sendfile        on;
            client_max_body_size 1000m;
            keepalive_timeout  65;
            # Disable tokens for security (#23684)
            server_tokens off;
            gzip  on;
            client_body_temp_path /var/tmp/firmware;
            server {
                server_name  {{ $nginx | trimAll "https://" }};
                listen                 0.0.0.0:{{ .Values.collaboraNetwork.webPort }} default_server ssl http2;
                ssl_certificate        "/etc/certs/server.crt";
                ssl_certificate_key    "/etc/certs/server.key";
                ssl_session_timeout    120m;
                ssl_session_cache      shared:ssl:16m;
                ssl_protocols TLSv1.2 TLSv1.3;
                ssl_prefer_server_ciphers on;
                ssl_ciphers EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA:EDH+aRSA:EECDH:!RC4:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!SHA1:!SHA256:!SHA384;
                add_header Strict-Transport-Security max-age=31536000;
                location = /robots.txt {
                  add_header Content-Type text/plain;
                  proxy_set_header Referer {{ $nginx | quote }};
                  return 200 "User-agent: *\nDisallow: /loleaflet/*\n";
                }
                # static files
                location ^~ /browser {
                    proxy_pass http://{{ $fullname }}:9980;
                    proxy_set_header Host $host;
                    # proxy_set_header Referer {{ $nginx | quote }};
                }
                # WOPI discovery URL
                location ^~ /hosting/discovery {
                    set $upstream_collabora {{ $fullname }};
                    proxy_pass http://$upstream_collabora:9980;
                    proxy_set_header Host $http_host;
                    # proxy_set_header Referer {{ $nginx | quote }};
                }
                # Capabilities
                location ^~ /hosting/capabilities {
                    proxy_pass http://{{ $fullname }}:9980;
                    proxy_set_header Host $host;
                    # proxy_set_header Referer {{ $nginx | quote }};
                }
                # main websocket
                location ~ ^/cool/(.*)/ws$ {
                    proxy_pass http://{{ $fullname }}:9980;
                    proxy_set_header Host $host;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "Upgrade";
                    # proxy_set_header Referer {{ $nginx | quote }};
                    proxy_read_timeout 36000s;
                }
                # download, presentation and image upload
                location ~ ^/(c|l)ool {
                    proxy_pass http://{{ $fullname }}:9980;
                    proxy_set_header Host $host;
                    proxy_set_header Referer {{ $nginx | quote }};
                }
                # Admin Console websocket
                location ^~ /cool/adminws {
                    proxy_pass http://{{ $fullname }}:9980;
                    proxy_set_header Host $host;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "Upgrade";
                    # proxy_set_header Referer {{ $nginx | quote }};
                    proxy_read_timeout 36000s;
                }
            }
        }

scaleCertificate:
  collabora-cert:
    enabled: true
    id: {{ .Values.collaboraNetwork.certificateID }}
  {{- end -}}
{{- end -}}
