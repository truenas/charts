{{- define "immich.server.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}
workload:
  server:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        server:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: immich-creds
            - configMapRef:
                name: server-config
          probes:
            liveness:
              enabled: true
              type: http
              path: /api/server-info/ping
              port: {{ .Values.immichNetwork.webuiPort }}
            readiness:
              enabled: true
              type: http
              path: /api/server-info/ping
              port: {{ .Values.immichNetwork.webuiPort }}
            startup:
              enabled: true
              type: http
              path: /api/server-info/ping
              port: {{ .Values.immichNetwork.webuiPort }}
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
{{- end -}}
