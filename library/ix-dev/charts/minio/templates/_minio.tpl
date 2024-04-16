{{- define "minio.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $logapi := printf "http://%v-log:8080" $fullname -}}
workload:
  minio:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.minioStorage.distributedMode }}
      containers:
        minio:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 473
            runAsGroup: 473
            # readOnlyRootFilesystem: false
          {{- if not .Values.minioStorage.distributedMode }}
          env:
            MINIO_VOLUMES: /export
          {{- end }}
          args:
            - server
            - --console-address
            - {{ printf ":%v" .Values.minioNetwork.consolePort | quote }}
            {{- if .Values.minioStorage.distributedMode }}
              {{- range .Values.minioStorage.distributedIps }}
            - {{ quote . }}
              {{- end }}
            {{- else }}
            - "--address"
            - {{ printf ":%v" .Values.minioNetwork.apiPort | quote }}
            {{- end }}
            {{- if .Values.minioNetwork.certificateID }}
            - "--certs-dir"
            - "/etc/minio/certs"
            {{- end }}
            {{- range .Values.minioConfig.extraArgs }}
            - {{ quote . }}
            {{ end }}
          envFrom:
            - secretRef:
                name: minio-creds
          {{ with .Values.minioConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{- $proto := "http" -}}
            {{- if .Values.minioNetwork.certificateID -}}
              {{- $proto = "https" -}}
            {{- end }}
            liveness:
              enabled: true
              type: {{ $proto }}
              path: /minio/health/live
              port: {{ .Values.minioNetwork.consolePort }}
            readiness:
              enabled: true
              type: {{ $proto }}
              path: /minio/health/live
              port: {{ .Values.minioNetwork.consolePort }}
            startup:
              enabled: true
              type: {{ $proto }}
              path: /minio/health/live
              port: {{ .Values.minioNetwork.consolePort }}
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 473
                                                        "GID" 473
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
      {{- if .Values.minioStorage.logSearchApi }}
        wait-api:
          enabled: true
          type: init
          imageSelector: bashImage
          command:
            - bash
          args:
            - -c
            - |
              echo "Waiting for [{{ $logapi }}]";
              until wget --spider --quiet --timeout=3 --tries=1 {{ $logapi }}/status;
              do
                echo "Waiting for [{{ $logapi }}]";
                sleep 2;
              done
              echo "API is up: {{ $logapi }}";
      {{- end }}
{{- end -}}
