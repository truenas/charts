{{- define "kapowarr.workload" -}}
workload:
  kapowarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        kapowarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
          {{ with .Values.kapowarrConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: 5656
              path: /
            readiness:
              enabled: true
              type: http
              port: 5656
              path: /
            startup:
              enabled: true
              type: http
              port: 5656
              path: /
{{- end -}}
