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
        - {{ .Values.fscrawlerConfig.jobName }}
      containers:
        fscrawler:
          enabled: true
          primary: true
          tty: true
          stdin: true
          imageSelector: {{ .Values.fscrawlerConfig.imageSelector }}
          securityContext:
            runAsUser: {{ .Values.fscrawlerRunAs.user }}
            runAsGroup: {{ .Values.fscrawlerRunAs.group }}
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
