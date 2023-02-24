{{- define "minio.workload" -}}
workload:
  minio:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.minio.network.host_network }}
      containers:
        minio:
          enabled: true
          primary: true
          imageSelector: image
          resources:
            limits:
              cpu: {{ .Values.resources.limits.cpu }}
              memory: {{ .Values.resources.limits.memory }}
          envFrom:
            - secretRef:
                name: minio-creds
            - configMapRef:
                name: minio-config
          args:
            - server
            - "--address"
            - {{ printf ":%v" .Values.minio.network.api_port | quote }}
            - "--console-address"
            - {{ printf ":%v" .Values.minio.network.web_port | quote }}
            {{- if .Values.minio.network.certificate_id }}
            - "--certs-dir"
            - "/.minio/certs"
            {{- end -}}
            {{- if .Values.minio.logging.anonymous }}
            - "--anonymous"
            {{- end -}}
            {{- if .Values.minio.logging.quiet }}
            - "--quiet"
            {{- end }}
          probes:
            liveness:
              enabled: true
              type: {{ include "minio.scheme" $ }}
              port: "{{ .Values.minio.network.api_port }}"
              path: /minio/health/live
            readiness:
              enabled: true
              type: {{ include "minio.scheme" $ }}
              port: "{{ .Values.minio.network.api_port }}"
              path: /minio/health/live
            startup:
              enabled: true
              type: {{ include "minio.scheme" $ }}
              port: "{{ .Values.minio.network.api_port }}"
              path: /minio/health/live
      initContainers:
      {{- include "minio.permissions" (dict "UID" 568 "GID" 568) | nindent 8 -}}
      {{- if .Values.logsearch.enabled }}
        logsearch-wait:
          enabled: true
          type: init
          imageSelector: bashImage
          resources:
            limits:
              cpu: 500m
              memory: 256Mi
          envFrom:
            - secretRef:
                name: minio-creds
          command: bash
          args:
            - -c
            - |
              until wget --spider --quiet --tries=1 ${MINIO_LOG_QUERY_URL}/status; do
                echo "Waiting for Logsearch API (${MINIO_LOG_QUERY_URL}/status) to be ready..."
                sleep 2
              done
              echo "Logsearch API is ready"
      {{- end }}
{{- end -}}
