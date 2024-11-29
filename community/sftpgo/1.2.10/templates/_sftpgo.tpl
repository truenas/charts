{{- define "sftpgo.workload" -}}
workload:
  sftpgo:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.sftpgoNetwork.hostNetwork }}
      terminationGracePeriodSeconds: {{ .Values.sftpgoConfig.graceTime }}
      containers:
        sftpgo:
          enabled: true
          primary: true
          imageSelector: {{ .Values.sftpgoConfig.imageSelector }}
          securityContext:
            runAsUser: {{ .Values.sftpgoRunAs.user }}
            runAsGroup: {{ .Values.sftpgoRunAs.group }}
          envFrom:
            - configMapRef:
                name: sftpgo-config
          {{ with .Values.sftpgoConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{- $protocol := "http" -}}
            {{- if .Values.sftpgoNetwork.certificateID -}}
              {{- $protocol = "https" -}}
            {{- end }}
            liveness:
              enabled: true
              type: {{ $protocol }}
              port: {{ .Values.sftpgoNetwork.webPort }}
              path: /healthz
            readiness:
              enabled: true
              type: {{ $protocol }}
              port: {{ .Values.sftpgoNetwork.webPort }}
              path: /healthz
            startup:
              enabled: true
              type: {{ $protocol }}
              port: {{ .Values.sftpgoNetwork.webPort }}
              path: /healthz
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.sftpgoRunAs.user
                                                        "GID" .Values.sftpgoRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
