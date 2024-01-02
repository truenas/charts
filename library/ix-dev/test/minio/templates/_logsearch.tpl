{{- define "logsearch.workload" -}}
workload:
  logsearch:
    enabled: true
    type: Deployment
    podSpec:
      containers:
        logsearch:
          enabled: true
          primary: true
          imageSelector: logsearchImage
          securityContext:
            runAsUser: {{ .Values.minioRunAs.user }}
            runAsGroup: {{ .Values.minioRunAs.group }}
          envFrom:
            - secretRef:
                name: logsearch-creds
          command: /logsearchapi
          probes:
            liveness:
              enabled: true
              type: http
              port: 8080
              path: /status
            readiness:
              enabled: true
              type: http
              port: 8080
              path: /status
            startup:
              enabled: true
              type: http
              port: 8080
              path: /status
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}

{{/* Service */}}
service:
  logsearch:
    enabled: true
    type: ClusterIP
    targetSelector: logsearch
    ports:
      logsearch:
        enabled: true
        primary: true
        port: 8080
        targetSelector: logsearch
{{- end -}}
