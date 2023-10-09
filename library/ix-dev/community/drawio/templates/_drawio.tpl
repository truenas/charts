{{- define "drawio.workload" -}}
workload:
  drawio:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.drawioNetwork.hostNetwork }}
      containers:
        drawio:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.drawioRunAs.user }}
            runAsGroup: {{ .Values.drawioRunAs.group }}
            readOnlyRootFilesystem: false
          env:
            DRAWIO_USE_HTTP: {{ ternary "1" "0" .Values.drawioNetwork.useHttp}}
          {{ with .Values.drawioConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{- $port := 8080 -}}
            {{- $protocol := "http" -}}
            {{- if not .Values.drawioNetwork.useHttp -}}
              {{- $protocol = "https" -}}
              {{- $port = 8443 -}}
            {{- end }}
            liveness:
              enabled: true
              type: {{ $protocol }}
              port: {{ $port }}
              path: /
            readiness:
              enabled: true
              type: {{ $protocol }}
              port: {{ $port }}
              path: /
            startup:
              enabled: true
              type: {{ $protocol }}
              port: {{ $port }}
              path: /
{{- end -}}
