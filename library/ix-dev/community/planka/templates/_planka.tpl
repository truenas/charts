{{- define "planka.workload" -}}
workload:
  planka:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.plankaNetwork.hostNetwork }}
      containers:
        planka:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
            readOnlyRootFilesystem: false
          env:
            PORT: {{ .Values.plankaNetwork.webPort }}
          envFrom:
            - secretRef:
                name: planka
            - configMapRef:
                name: planka
          {{ with .Values.plankaConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.plankaNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.plankaNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.plankaNetwork.webPort }}
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1000
                                                        "GID" 1000
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
