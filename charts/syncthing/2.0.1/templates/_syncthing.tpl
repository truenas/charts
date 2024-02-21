{{- define "syncthing.workload" -}}
workload:
  syncthing:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      securityContext:
        fsGroup: {{ .Values.syncthingID.group }}
      hostNetwork: {{ .Values.syncthingNetwork.hostNetwork }}
      containers:
        syncthing:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            # This is needed to allow syncthing assign
            # PCAPs to its child processes
            allowPrivilegeEscalation: true
            capabilities:
              add:
                - FOWNER
                - DAC_OVERRIDE
                - CHOWN
                - SETUID
                - SETGID
                - SETFCAP
                - SETPCAP
                - SYS_ADMIN
          env:
            STGUIADDRESS: 0.0.0.0:{{ .Values.syncthingNetwork.webPort }}
            STNOUPGRADE: "true"
          fixedEnv:
            PUID: {{ .Values.syncthingID.user }}
          {{ with .Values.syncthingConfig.additionalEnvs }}
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
              path: /rest/noauth/health
              port: {{ .Values.syncthingNetwork.webPort }}
            readiness:
              enabled: true
              type: http
              path: /rest/noauth/health
              port: {{ .Values.syncthingNetwork.webPort }}
            startup:
              enabled: true
              type: http
              path: /rest/noauth/health
              port: {{ .Values.syncthingNetwork.webPort }}
{{- end -}}
