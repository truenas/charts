{{- define "immich.server.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $typesenseUrl := printf "http://%v-typesense:%v/health" $fullname .Values.immichNetwork.typesensePort }}
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
          command: /bin/sh
          args:
            - -c
            - /usr/src/app/start-server.sh
          envFrom:
            - secretRef:
                name: immich-creds
            - configMapRef:
                name: server-config
          probes:
            liveness:
              enabled: true
              type: http
              path: /server-info/ping
              port: {{ .Values.immichNetwork.serverPort }}
            readiness:
              enabled: true
              type: http
              path: /server-info/ping
              port: {{ .Values.immichNetwork.serverPort }}
            startup:
              enabled: true
              type: http
              path: /server-info/ping
              port: {{ .Values.immichNetwork.serverPort }}
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
      {{- if .Values.immichConfig.enableTypesense }}
        {{- include "immich.wait.init" (dict "url" $typesenseUrl) | indent 8 }}
      {{- end }}
{{- end -}}
