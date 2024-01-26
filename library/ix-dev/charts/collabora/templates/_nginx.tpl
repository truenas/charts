{{- define "nginx.workload" -}}
workload:
  nginx:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        nginx:
          enabled: true
          primary: true
          imageSelector: nginxImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            # capabilities:
            #   add:
            #     - NET_BIND_SERVICE
            #     - NET_RAW
          probes:
            liveness:
              enabled: true
              type: https
              path: /robots.txt
              port: 443
            readiness:
              enabled: true
              type: https
              path: /robots.txt
              port: 443
            startup:
              enabled: true
              type: https
              path: /robots.txt
              port: 443
{{- end -}}
