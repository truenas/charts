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
            - secretRef:
                name: immich-creds
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
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
      # TODO: Add init container to wait for redis
      # TODO: Add init container to wait for server
{{- end -}}
