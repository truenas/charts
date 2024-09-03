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
                                                        "type" "install") | nindent 8 }}
        {{- $migrate := false -}}
        {{- if (hasKey .Values.global "ixChartContext") -}}
          {{- if (hasKey .Values.global.ixChartContext "upgradeMetadata") -}}
            {{- with .Values.global.ixChartContext.upgradeMetadata -}}
              {{- $ver := semver (.oldChartVersion | default "0.0.0") -}}
              {{/* Enable migrate script if old version is below 1.2.x */}}
              {{- if and (eq $ver.Major 1) (lt $ver.Minor 2) -}}
                {{- $migrate = true -}}
              {{- end -}}
            {{- end -}}
          {{- end -}}
        {{- end }}
        02-migrate:
          enabled: {{ $migrate }}
          type: init
          imageSelector: image
          securityContext:
            runAsUser: 999
            runAsGroup: 999
            readOnlyRootFilesystem: false
          command:
            - /bin/bash
          args:
            - -c
            - |
              newdatadir="/usr/lib/unifi/data"
              olddatadir="/usr/lib/unifi/data/data"
              # Check the dir exists
              [ ! -d "$newdatadir" ] && echo "$newdatadir missing" && exit 1
              # Check if there is a data/data dir to migrate
              [ ! -d "$olddatadir" ] && echo "No $olddatadir dir found. Migration skipped" && exit 0

              # Check if the new data dir is empty, ignoring the old data dir
              dirs=$(ls -A "$newdatadir" | grep -v "data")
              if [ -n "$dirs" ]; then
                echo "New data dir is empty. Migrating data one level up"
                mv $olddatadir/* $newdatadir || echo "Failed to move data" && exit 1
                # Remove the data/data dir
                rm -rf $olddatadir
                echo "Data migration complete"
              fi
{{- end -}}
