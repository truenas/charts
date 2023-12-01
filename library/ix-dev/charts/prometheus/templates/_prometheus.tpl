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
    {{- include "prometheus.storage.ci.migration" (dict "storage" .Values.prometheusStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.prometheusStorage.data) | nindent 4 }}
    targetSelector:
      prometheus:
        prometheus:
          mountPath: /data
  config:
    enabled: true
    {{- include "prometheus.storage.ci.migration" (dict "storage" .Values.prometheusStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.prometheusStorage.config) | nindent 4 }}
    targetSelector:
      prometheus:
        prometheus:
          mountPath: /config
        init-config:
          mountPath: /config
  {{- range $idx, $storage := .Values.prometheusStorage.additionalStorages }}
  {{ printf "prometheus-%v:" (int $idx) }}
    enabled: true
    {{- include "prometheus.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      prometheus:
        prometheus:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.1.0+ */}}
{{- define "prometheus.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
