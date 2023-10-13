{{- define "distribution.workload" -}}
workload:
  distribution:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.distributionNetwork.hostNetwork }}
      containers:
        distribution:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.distributionRunAs.user }}
            runAsGroup: {{ .Values.distributionRunAs.group }}
            readOnlyRootFilesystem: false
          envFrom:
            - configMapRef:
                name: distribution-config
          {{ with .Values.distributionConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{- $protocol := "http" -}}
            {{- if .Values.distributionNetwork.certificateID -}}
              {{- $protocol = "https" -}}
            {{- end }}
            liveness:
              enabled: true
              type: {{ $protocol }}
              port: {{ .Values.distributionNetwork.apiPort }}
              path: /
            readiness:
              enabled: true
              type: {{ $protocol }}
              port: {{ .Values.distributionNetwork.apiPort }}
              path: /
            startup:
              enabled: true
              type: {{ $protocol }}
              port: {{ .Values.distributionNetwork.apiPort }}
              path: /
{{- end -}}
