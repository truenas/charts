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
        db-wait:
          enabled: true
          type: init
          imageSelector: postgresImage
          envFrom:
            - secretRef:
                name: postgres-creds
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
