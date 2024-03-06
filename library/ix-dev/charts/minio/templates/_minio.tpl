{{- define "minio.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $logapi := printf "http://%v-log:8080" $fullname -}}
{{ $args := list "server" (printf "--console-address=':%v'" .Values.minioNetwork.consolePort) }}
workload:
  minio:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.minioConfig.distributedMode }}
      containers:
        minio:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 473
            runAsGroup: 473
            # readOnlyRootFilesystem: false
          args:
            {{- if .Values.minioNetwork.certificateID }}
              {{- $args = mustAppend $args (printf "--certs-dir '/etc/minio/certs'") }}
            {{- end }}
            {{- if .Values.minioConfig.distributedMode }}
              {{- $args = concat $args (.Values.minioConfig.distributedIps | default list) }}
              {{- $args = concat $args (.Values.minioConfig.extraArgs | default list) }}
            {{- else }}
              {{- $args = mustAppend $args (printf "--address ':%v'" .Values.minioNetwork.apiPort) }}
              {{- $args = mustAppend $args "/export" }} {{/* TODO: this is not hardcoded in UI */}}
              {{- $args = concat $args (.Values.minioConfig.extraArgs | default list) }}
            {{- end }}
            - {{ $args | join " " | quote }}
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
      initContainers: {{/* TODO: check mode */}}
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 473
                                                        "GID" 473
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
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
{{- end -}}
