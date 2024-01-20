{{- define "tmm.workload" -}}
workload:
  tmm:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      securityContext:
        fsGroup: {{ .Values.tmmID.group }}
      containers:
        tmm:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - SETUID
                - SETGID
                - CHOWN
          fixedEnv:
            PUID: {{ .Values.tmmID.user }}
          env:
            PASSWORD: {{ .Values.tmmConfig.password }}
          {{ with .Values.tmmConfig.additionalEnvs }}
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
              port: 4000
              path: /
            readiness:
              enabled: true
              type: http
              port: 4000
              path: /
            startup:
              enabled: true
              type: http
              port: 4000
              path: /
{{- end -}}
