{{- define "fscrawler.workload" -}}
workload:
  fscrawler:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.fscrawlerNetwork.hostNetwork }}
      command:
        - fscrawler
      args:
        - --config_dir
        - /jobs
        - {{ .Values.fscrawlerConfig.jobName | quote }}
        - --loop
        - {{ .Values.fscrawlerConfig.loop | quote }}
        - --restart
      containers:
        fscrawler:
          enabled: true
          primary: true
          tty: true
          stdin: true
          imageSelector: {{ .Values.fscrawlerConfig.imageSelector }}
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          {{ with .Values.fscrawlerConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            # Nothing to probe
            liveness:
              enabled: false
            readiness:
              enabled: false
            startup:
              enabled: false
{{- end -}}
