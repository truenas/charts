{{- define "sabnzbd.workload" -}}
workload:
  sabnzbd:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.sabnzbdNetwork.hostNetwork }}
      containers:
        sabnzbd:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.sabnzbdRunAs.user }}
            runAsGroup: {{ .Values.sabnzbdRunAs.group }}
          env:
            SABNZBD__PORT: {{ .Values.sabnzbdNetwork.webPort }}
          {{ with .Values.sabnzbdConfig.additionalEnvs }}
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
              port: "{{ .Values.sabnzbdNetwork.webPort }}"
              path: /api?mode=version
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.sabnzbdNetwork.webPort }}"
              path: /api?mode=version
            startup:
              enabled: true
              type: http
              port: "{{ .Values.sabnzbdNetwork.webPort }}"
              path: /api?mode=version
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.sabnzbdRunAs.user
                                                        "GID" .Values.sabnzbdRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
