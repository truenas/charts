{{- define "palworld.workload" -}}
workload:
  palworld:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.palworldNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.palworldID.group }}
      containers:
        palworld:
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
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETGID
                - SETUID
                - KILL
          env:
            STEAMCMD_DIR: /serverdata/steamcmd
            SERVER_DIR: /serverdata/serverfiles
            SRV_ADMIN_PWD: {{ .Values.palworldConfig.adminPassword }}
            GAME_PARAMS: {{ join " " .Values.palworldConfig.gameParams }}
            GAME_PARAMS_EXTRA: {{ join " " .Values.palworldConfig.gameParamsExtra }}
            UPDATE_PUBLIC_IP: {{ .Values.palworldConfig.updatePublicIP }}
            VALIDATE: {{ .Values.palworldConfig.validate }}
            USERNAME: {{ .Values.palworldConfig.username }}
            PASSWORD: {{ .Values.palworldConfig.password }}
          fixedEnv:
            PUID: {{ .Values.palworldID.user }}
          {{ with .Values.palworldConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command:
                - pgrep
                - PalServer-Linux
            readiness:
              enabled: true
              type: exec
              command:
                - pgrep
                - PalServer-Linux
            startup:
              enabled: true
              type: exec
              command:
                - pgrep
                - PalServer-Linux
{{- end -}}
