{{- define "immich.typesense.workload" -}}
workload:
  typesense:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        typesense:
          enabled: true
          primary: true
          imageSelector: typesenseImage
          args:
            - --api-port
            - {{ .Values.immichNetwork.typesensePort | quote }}
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: typesense-creds
          probes:
            liveness:
              enabled: true
              type: http
              path: /health
              port: {{ .Values.immichNetwork.typesensePort }}
            readiness:
              enabled: true
              type: http
              path: /health
              port: {{ .Values.immichNetwork.typesensePort }}
            startup:
              enabled: true
              type: http
              path: /health
              port: {{ .Values.immichNetwork.typesensePort }}
      initContainers: []
      # TODO: Add init container to wait for server
{{- end -}}
