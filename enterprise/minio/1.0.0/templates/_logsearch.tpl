{{- define "logsearch.workload" -}}
{{- if .Values.logsearch.enabled }}
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
          resources:
            limits:
              cpu: {{ .Values.resources.limits.cpu }}
              memory: {{ .Values.resources.limits.memory }}
          envFrom:
            - secretRef:
                name: logsearch-creds
            - configMapRef:
                name: logsearch-config
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
        db-wait:
          enabled: true
          type: init
          imageSelector: postgresImage
          envFrom:
            - configMapRef:
                name: postgres-config
          resources:
            limits:
              cpu: 500m
              memory: 256Mi
          command: bash
          args:
            - -c
            - |
              echo "Waiting for postgres to be ready"
              until pg_isready -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -d ${POSTGRES_DB}; do
                sleep 2
              done
  {{- end -}}
{{- end -}}
