{{- define "flame.workload" -}}
workload:
  flame:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.flameNetwork.hostNetwork }}
      containers:
        flame:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            # FIXME: https://github.com/pawelmalak/flame/pull/356
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
          envFrom:
            - secretRef:
                name: flame-config
          {{ with .Values.flameConfig.additionalEnvs }}
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
              port: {{ .Values.flameNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.flameNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.flameNetwork.webPort }}
              path: /
{{- end -}}
