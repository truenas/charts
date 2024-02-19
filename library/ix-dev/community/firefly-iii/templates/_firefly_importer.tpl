{{- define "firefly.importer" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}
workload:
  firefly-importer:
    enabled: true
    type: Deployment
    podSpec:
      containers:
        firefly-importer:
          enabled: true
          primary: true
          imageSelector: importerImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - FOWNER
                - SETUID
                - SETGID
          envFrom:
            - secretRef:
                name: importer-config
          {{ with .Values.fireflyConfig.additionalImporterEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value | quote }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              path: /health
              port: 8080
            readiness:
              enabled: true
              type: http
              path: /health
              port: 8080
            startup:
              enabled: true
              type: http
              path: /health
              port: 8080
      initContainers:
        firefly-wait:
          enabled: true
          type: init
          imageSelector: bashImage
          command:
            - bash
          args:
            - -c
            - |
              until wget --spider --quiet --timeout=3 --tries=1 \
                http://{{ $fullname }}:{{ .Values.fireflyNetwork.webPort }}/health;
              do
                echo "Waiting for Firefly III to be ready..."
                sleep 2
              done

{{- end -}}
