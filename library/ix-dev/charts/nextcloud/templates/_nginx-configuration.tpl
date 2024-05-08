{{- define "nginx.configuration" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

{{- if .Values.ncNetwork.certificateID }}
scaleCertificate:
  nextcloud-cert:
    enabled: true
    id: {{ .Values.ncNetwork.certificateID }}

  {{ $timeout := 60 }}
  {{ $size := .Values.ncConfig.maxUploadLimit | default 3 }}
  {{ $useDiffAccessPort := false }}
  {{ $externalAccessPort := ":$server_port" }}
  {{/* Safely access key as it is conditionaly shown */}}
  {{ if hasKey .Values.ncNetwork "nginx" }}
    {{ $useDiffAccessPort = .Values.ncNetwork.nginx.useDifferentAccessPort }}
    {{ $externalAccessPort = printf ":%v" .Values.ncNetwork.nginx.externalAccessPort }}
    {{ $timeout = .Values.ncNetwork.nginx.proxyTimeouts | default 60 }}
  {{ end }}
  {{/* If its 443, do not append it on the rewrite at all */}}
  {{ if eq $externalAccessPort ":443" }}
    {{ $externalAccessPort = "" }}
  {{ end }}
configmap:
  nginx:
    enabled: true
    data:
      nginx.conf: |
        events {}
        http {
          server {
            listen {{ .Values.ncNetwork.webPort }} ssl http2;
            listen [::]:{{ .Values.ncNetwork.webPort }} ssl http2;

            # Redirect HTTP to HTTPS
            error_page 497 301 =307 https://$host{{ $externalAccessPort }}$request_uri;

            ssl_certificate '/etc/nginx-certs/public.crt';
            ssl_certificate_key '/etc/nginx-certs/private.key';

            client_max_body_size {{ $size }}G;

            add_header Strict-Transport-Security "max-age=15552000; includeSubDomains; preload" always;

            location = /robots.txt {
              allow all;
              log_not_found off;
              access_log off;
            }

            location = /.well-known/carddav {
              return 301 $scheme://$host{{ $externalAccessPort }}/remote.php/dav;
            }

            location = /.well-known/caldav {
              return 301 $scheme://$host{{ $externalAccessPort }}/remote.php/dav;
            }

            location / {
              proxy_pass http://{{ $fullname }}:80;
              proxy_http_version                 1.1;
              proxy_cache_bypass                 $http_upgrade;
              proxy_request_buffering            off;

              # Proxy headers
              proxy_set_header Upgrade           $http_upgrade;
              proxy_set_header Connection        "upgrade";
              proxy_set_header Host              $http_host;
              proxy_set_header X-Real-IP         $remote_addr;
              proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto https;
              proxy_set_header X-Forwarded-Host  $host;
              proxy_set_header X-Forwarded-Port  {{ $externalAccessPort | default "443" | trimPrefix ":" }};

              # Proxy timeouts
              proxy_connect_timeout              {{ $timeout }}s;
              proxy_send_timeout                 {{ $timeout }}s;
              proxy_read_timeout                 {{ $timeout }}s;
            }
          }
        }
{{- end -}}
{{- end -}}
