{{- define "logsearchapi.workload" -}}
workload:
  logsearchapi:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        logsearchapi:
          enabled: true
          primary: true
          imageSelector: logSearchImage
          securityContext:
            runAsUser: 473
            runAsGroup: 473
          command:
            - /logsearchapi
          envFrom:
            - secretRef:
                name: logsearch-creds
          probes:
            liveness:
              enabled: true
              type: http
              path: /status
              port: 8080
            readiness:
              enabled: true
              type: http
              path: /status
              port: 8080
            startup:
              enabled: true
              type: http
              path: /status
              port: 8080
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
