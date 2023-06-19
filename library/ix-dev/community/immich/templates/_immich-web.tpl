{{- define "immich.web.workload" -}}
workload:
  web:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        web:
          enabled: true
          primary: true
          imageSelector: webImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - configMapRef:
                name: web-config
          probes:
            liveness:
              enabled: true
              type: http
              path: /robots.txt
              port: {{ .Values.immichNetwork.webPort }}
            readiness:
              enabled: true
              type: http
              path: /robots.txt
              port: {{ .Values.immichNetwork.webPort }}
            startup:
              enabled: true
              type: http
              path: /robots.txt
              port: {{ .Values.immichNetwork.webPort }}
      initContainers: []
      # TODO: Add init container to wait for server
{{- end -}}
