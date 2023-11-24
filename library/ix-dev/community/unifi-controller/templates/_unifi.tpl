{{- define "unifi.workload" -}}
workload:
  unifi:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.unifiNetwork.hostNetwork }}
      containers:
        unifi:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 999
            runAsGroup: 999
            readOnlyRootFilesystem: false
          env:
            DB_MONGO_LOCAL: true
            RUN_CHOWN: false
            RUNAS_UID0: false
            UNIFI_HTTP_PORT: {{ .Values.unifiNetwork.webHttpPort }}
            UNIFI_HTTPS_PORT: {{ .Values.unifiNetwork.webHttpsPort }}
            PORTAL_HTTP_PORT: {{ .Values.unifiNetwork.portalHttpPort }}
            PORTAL_HTTPS_PORT: {{ .Values.unifiNetwork.portalHttpsPort }}
          {{ with .Values.unifiConfig.additionalEnvs }}
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
              command: /usr/local/bin/docker-healthcheck.sh
            readiness:
              enabled: true
              type: exec
              command: /usr/local/bin/docker-healthcheck.sh
            startup:
              enabled: true
              type: exec
              command: /usr/local/bin/docker-healthcheck.sh
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 999
                                                        "GID" 999
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
        migrate:
          enabled: true
          imageSelector: image
          securityContext:
            runAsUser: 999
            runAsGroup: 999
            readOnlyRootFilesystem: false
          command:
            - /bin/sh
          args:
            - -c
            - |
              # Check the dir exists
              if [ -d /usr/lib/unifi/data ]; then
                # If the data/data dir exists, move the files one level up
                echo "Checking if data/data dir exists"
                if [ -d /usr/lib/unifi/data/data ]; then
                  echo "Checking if data dir is empty"
                  if [ ! $(ls -A /usr/lib/unifi/data | grep -v "data") ]; then
                    echo "Migrating data one level up"
                    mv /usr/lib/unifi/data/data/* /usr/lib/unifi/data || exit 1
                    # Remove the data/data dir
                    rm -rf /usr/lib/unifi/data/data
                  fi
                fi
              fi
{{- end -}}
