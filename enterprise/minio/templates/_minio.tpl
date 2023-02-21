{{- define "minio.workload" -}}
enabled: true
primary: true
type: Deployment
podSpec:
  containers:
    minio:
      enabled: true
      primary: true
      imageSelector: image
      envFrom:
        - secretRef:
            name: minio-creds
        - configMapRef:
            name: minio-config
      args:
        - server
        {{- range $addr := .Values.minio.network.distributed_addresses }}
        - {{ $addr | quote }}
        {{- end }}
        - "--address"
        - ":{{ .Values.minio.network.api_port }}"
        - "--console-address"
        - ":{{ .Values.minio.network.web_port }}"
        - "--certs-dir"
        - "/etc/minio/certs"
        {{- if .Values.minio.logging.anonymous }}
        - "--anonymous"
        {{- end }}
        {{- if .Values.minio.logging.quiet }}
        - "--quiet"
        {{- end }}

      probes:
        liveness:
          enabled: true
          type: http
          port: "{{ .Values.minio.network.api_port }}"
          path: /minio/health/live
        readiness:
          enabled: true
          type: http
          port: "{{ .Values.minio.network.api_port }}"
          path: /minio/health/live
        startup:
          enabled: true
          type: http
          port: "{{ .Values.minio.network.api_port }}"
          path: /minio/health/live
{{- end -}}
