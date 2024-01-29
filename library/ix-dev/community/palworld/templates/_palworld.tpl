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
              if [ ! -d ${config} ]; then
                echo "Config directory not found, creating..."
                mkdir -p ${config}
              fi
              if [ ! -f ${cfgFile} ]; then
                echo "Config file not found, fetching..."
                # -- Fetch the config file if it doesn't exist, just like the container does
                wget -qO ${cfgFile} https://github.com/ich777/docker-steamcmd-server/raw/palworld/config/PalWorldSettings.ini
              fi

              set_ini_value() {
                local key="${1}"
                local value="${2}"
                local print="${3:-true}"
                # -- Escape special characters for sed
                escaped_value=$(printf '%s\n' "$value" | sed 's/[&/\]/\\&/g')
                # -- Check if the value contains spaces or special characters
                if echo "$escaped_value" | grep -vE "(T|t)rue|(F|f)alse" | grep -q '[[:space:]]\|[^\w.-]'; then
                  # -- Add quotes around the value
                  escaped_value="\"$escaped_value\""
                fi
                echo "Setting ${key}..."
                sed -i "s|\(${key}=\)[^,]*|\1${escaped_value}|g" "${cfgFile}"
                if [ "$print" = true ]; then
                  echo "Set to $(grep -Po "(?<=${key}=)[^,]*" "${cfgFile}")"
                fi
              }

              set_ini_value "RCONEnabled" True
              set_ini_value "RCONPort" {{ .Values.palworldNetwork.rconPort }}
              set_ini_value "PublicPort" {{ .Values.palworldNetwork.serverPort }}
              set_ini_value "ServerName" {{ .Values.palworldConfig.server.name | quote }}
              set_ini_value "ServerDescription" {{ .Values.palworldConfig.server.description | quote }}
              set_ini_value "ServerPassword" {{ .Values.palworldConfig.server.password | squote }} false
              set_ini_value "AdminPassword" {{ .Values.palworldConfig.adminPassword | squote }} false

              {{- range $item := .Values.palworldConfig.iniKeys }}
                {{- if mustHas (kindOf $item.value) (list "int" "int64" "float64") }}
                  echo "Key {{ $item.key }} is a {{ kindOf $item.value }}, setting without quotes..."
                  set_ini_value "{{ $item.key }}" {{ $item.value }}
                {{- else if or (eq ((toString $item.value) | lower) "true") (eq ((toString $item.value) | lower) "false") }}
                  echo "Key {{ $item.key }} is a boolean, setting without quotes..."
                  set_ini_value "{{ $item.key }}" {{ (toString $item.value) | camelcase }}
                {{- else }}
                  echo "Key {{ $item.key }} is a {{ kindOf $item.value }}, setting with quotes..."
                  set_ini_value "{{ $item.key }}" {{ $item.value | quote }}
                {{- end }}
              {{- end }}

              echo "Done!"
{{- end -}}
