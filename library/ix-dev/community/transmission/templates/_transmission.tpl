{{- define "transmission.workload" -}}
workload:
  transmission:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.transmissionNetwork.hostNetwork }}
      containers:
        transmission:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.transmissionRunAs.user }}
            runAsGroup: {{ .Values.transmissionRunAs.group }}
          {{ with .Values.transmissionConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          envFrom:
            - configMapRef:
                name: transmission-config
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.transmissionNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.transmissionNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.transmissionNetwork.webPort }}
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.transmissionRunAs.user
                                                        "GID" .Values.transmissionRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}

{{- end -}}
