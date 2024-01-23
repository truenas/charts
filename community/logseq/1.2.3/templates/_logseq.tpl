{{- define "logseq.workload" -}}
workload:
  logseq:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.logseqNetwork.hostNetwork }}
      containers:
        logseq:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.logseqRunAs.user }}
            runAsGroup: {{ .Values.logseqRunAs.group }}
            readOnlyRootFilesystem: false
          {{ with .Values.logseqConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{- $protocol := "http" -}}
            {{- if .Values.logseqNetwork.certificateID -}}
              {{- $protocol = "https" -}}
            {{- end }}
            liveness:
              enabled: true
              type: {{ $protocol }}
              port: {{ .Values.logseqNetwork.webPort }}
              path: /health
            readiness:
              enabled: true
              type: {{ $protocol }}
              port: {{ .Values.logseqNetwork.webPort }}
              path: /health
            startup:
              enabled: true
              type: {{ $protocol }}
              port: {{ .Values.logseqNetwork.webPort }}
              path: /health
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.logseqRunAs.user
                                                        "GID" .Values.logseqRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
