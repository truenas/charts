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
          envFrom:
            - secretRef:
                name: distribution-creds
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
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.distributionRunAs.user
                                                        "GID" .Values.distributionRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
