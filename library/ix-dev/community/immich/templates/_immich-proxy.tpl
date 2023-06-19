{{- define "immich.proxy.workload" -}}
workload:
  proxy:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        proxy:
          enabled: true
          primary: true
          imageSelector: proxyImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - configMapRef:
                name: proxy-config
          probes:
            liveness:
              enabled: true
              type: http
              path: /api/server-info/ping
              port: 8080
            readiness:
              enabled: true
              type: http
              path: /api/server-info/ping
              port: 8080
            startup:
              enabled: true
              type: http
              path: /api/server-info/ping
              port: 8080
      initContainers: []
      # TODO: Add init container to wait for server
{{- end -}}
