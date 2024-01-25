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
                - SYS_RESOURCE
                - KILL
          env:
            STEAMCMD_DIR: /serverdata/steamcmd
            {{- $srvDir := "/serverdata/serverfiles" }}
            SERVER_DIR: {{ $srvDir }}
            # This var does not seem to be used from the container script
            # But is documented in the README, we currently update the password
            # with the initContainer, keeping this here to avoid inconsistencies
            # in case the container script is updated
            SRV_ADMIN_PWD: {{ .Values.palworldConfig.adminPassword }}
            GAME_PARAMS: {{ join " " .Values.palworldConfig.gameParams }}
            GAME_PARAMS_EXTRA: {{ join " " .Values.palworldConfig.gameParamsExtra }}
            UPDATE_PUBLIC_IP: {{ .Values.palworldConfig.updatePublicIP }}
            VALIDATE: {{ .Values.palworldConfig.validate }}
            USERNAME: {{ .Values.palworldConfig.username }}
            PASSWORD: {{ .Values.palworldConfig.password }}
            BACKUP: {{ .Values.palworldConfig.backup.enabled | default false }}
            BACKUP_INTERVAL: {{ .Values.palworldConfig.backup.interval | default 120 }}
            BACKUPS_TO_KEEP: {{ .Values.palworldConfig.backup.keep | default 3 }}
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
              echo "Setting Server Name..."
              sed -i 's/\(ServerName=\)[^,]*/\1{{ .Values.palworldConfig.server.name | quote }}/g' ${cfgFile}
              echo "Set to [$(grep -Po 'ServerName=[^,]*' ${cfgFile})]"
              echo "Setting Server Description..."
              sed -i 's/\(ServerDescription=\)[^,]*/\1{{ .Values.palworldConfig.server.description | quote }}/g' ${cfgFile}
              echo "Set to [$(grep -Po 'ServerDescription=[^,]*' ${cfgFile})]"
              echo "Setting Server Password..."
              sed -i 's/\(ServerPassword=\)[^,]*/\1{{ .Values.palworldConfig.server.password | quote }}/g' ${cfgFile}
              echo "Server Password set..."
              echo "Setting Admin Password..."
              sed -i 's/\(AdminPassword=\)[^,]*/\1{{ .Values.palworldConfig.adminPassword | quote }}/g' ${cfgFile}
              echo "Admin Password set..."
              echo "Done!"
{{- end -}}
