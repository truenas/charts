{{- define "prometheus.workload" -}}
workload:
  prometheus:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.prometheusNetwork.hostNetwork }}
      containers:
        prometheus:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.prometheusRunAs.user }}
            runAsGroup: {{ .Values.prometheusRunAs.group }}
          args:
            - --web.listen-address=0.0.0.0:{{ .Values.prometheusNetwork.apiPort }}
            - --storage.tsdb.path=/data
            - --config.file=/config/prometheus.yml
            - --storage.tsdb.retention.time={{ .Values.prometheusConfig.retentionTime }}
            {{ with .Values.prometheusConfig.retentionSize }}
            - --storage.tsdb.retention.size={{ . }}
            {{ end }}
            {{ if .Values.prometheusConfig.walCompression }}
            - --storage.tsdb.wal-compression
            {{ end }}
          {{ with .Values.prometheusConfig.additionalArgs }}
          extraArgs:
            {{ range $arg := . }}
            - {{ $arg | quote }}
            {{ end }}
          {{ end }}
          {{ with .Values.prometheusConfig.additionalEnvs }}
          env:
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.prometheusNetwork.apiPort }}
              path: /-/healthy
            readiness:
              enabled: true
              type: http
              port: {{ .Values.prometheusNetwork.apiPort }}
              path: /-/ready
            startup:
              enabled: true
              type: http
              port: {{ .Values.prometheusNetwork.apiPort }}
              path: /-/ready
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.prometheusRunAs.user
                                                        "GID" .Values.prometheusRunAs.group
                                                        "type" "install") | nindent 8 }}
        init-config:
          enabled: true
          type: init
          imageSelector: image
          resources:
            limits:
              cpu: 500m
              memory: 256Mi
          securityContext:
            runAsUser: {{ .Values.prometheusRunAs.user }}
            runAsGroup: {{ .Values.prometheusRunAs.group }}
          command: sh
          args:
            - -c
            - |
              if [ ! -f /config/prometheus.yml ]; then
                touch /config/prometheus.yml
              fi
{{/* Service */}}
service:
  prometheus:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: prometheus
    ports:
      prometheus:
        enabled: true
        primary: true
        port: {{ .Values.prometheusNetwork.apiPort }}
        nodePort: {{ .Values.prometheusNetwork.apiPort }}
        targetSelector: prometheus

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.prometheusStorage.data.type }}
    datasetName: {{ .Values.prometheusStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.prometheusStorage.data.hostPath | default "" }}
    targetSelector:
      prometheus:
        prometheus:
          mountPath: /data
        01-permissions:
          mountPath: /mnt/directories/data
  config:
    enabled: true
    type: {{ .Values.prometheusStorage.config.type }}
    datasetName: {{ .Values.prometheusStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.prometheusStorage.config.hostPath | default "" }}
    targetSelector:
      prometheus:
        prometheus:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/export
        init-config:
          mountPath: /config
{{- end -}}
