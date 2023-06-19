{{- define "immich.machinelearning.workload" -}}
workload:
  machinelearning:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        machinelearning:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - configMapRef:
                name: ml-config
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.immichNetwork.machinelearningPort }}
              path: /ping
            readiness:
              enabled: true
              type: http
              port: {{ .Values.immichNetwork.machinelearningPort }}
              path: /ping
            startup:
              enabled: true
              type: http
              port: {{ .Values.immichNetwork.machinelearningPort }}
              path: /ping
      initContainers: []
      # TODO: Add init container to wait for server
{{- end -}}
