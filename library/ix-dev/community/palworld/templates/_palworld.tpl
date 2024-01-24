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
            {{- $srvDir := "/serverdata/serverfiles" }}
            SERVER_DIR: {{ $srvDir }}
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
              type: tcp
              port: {{ .Values.palworldNetwork.rconPort }}
            readiness:
              enabled: true
              type: tcp
              port: {{ .Values.palworldNetwork.rconPort }}
            startup:
              enabled: true
              type: tcp
              port: {{ .Values.palworldNetwork.rconPort }}
      initContainers:
        01-config:
          enabled: true
          type: init
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
          command: /bin/bash
          args:
            - -c
            - |
              config={{ $srvDir }}/Pal/Saved/Config/LinuxServer
              cfgFile=${config}/PalWorldSettings.ini
              mkdir -p ${config}
              if [ ! -f ${cfgFile} ]; then
                echo "Config file not found, fetching..."
                # Fetch the config file if it doesn't exist, just like the container does
                wget -qO ${cfgFile} https://github.com/ich777/docker-steamcmd-server/raw/palworld/config/PalWorldSettings.ini
              fi
              echo "Setting RCON status..."
              sed -i 's/\(RCONEnabled=\)[^,]*/\1True/g' ${cfgFile}
              echo "Set to [$(grep -Po 'RCONEnabled=[^,]*' ${cfgFile})]"
              echo "Setting RCON Port..."
              sed -i 's/\(RCONPort=\)[^,]*/\1{{ .Values.palworldNetwork.rconPort }}/g' ${cfgFile}
              echo "Set to [$(grep -Po 'RCONPort=[^,]*' ${cfgFile})]"
              echo "Setting Game Port..."
              sed -i 's/\(PublicPort=\)[^,]*/\1{{ .Values.palworldNetwork.serverPort }}/g' ${cfgFile}
              echo "Set to [$(grep -Po 'PublicPort=[^,]*' ${cfgFile})]"
              echo "Done!"
{{- end -}}
