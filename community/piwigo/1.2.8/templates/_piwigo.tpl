{{- define "piwigo.workload" -}}
workload:
  piwigo:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      securityContext:
        fsGroup: {{ .Values.piwiID.group }}
      containers:
        piwigo:
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
                - NET_BIND_SERVICE
                - SETGID
                - SETUID
          envFrom:
            - secretRef:
                name: piwigo-creds
          fixedEnv:
            PUID: {{ .Values.piwiID.user }}
          {{ with .Values.piwiConfig.additionalEnvs }}
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
              # https://github.com/Piwigo/Piwigo/issues/1954
              path: /ws.php?method=pwg.session.getStatus
              port: 80
            readiness:
              enabled: true
              type: http
              path: /ws.php?method=pwg.session.getStatus
              port: 80
            startup:
              enabled: true
              type: http
              path: /ws.php?method=pwg.session.getStatus
              port: 80
          lifecycle:
            postStart:
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  until curl --silent --fail --output /dev/null http://localhost:80; do
                    echo "Waiting for Piwigo to start..."
                    sleep 1
                  done
                  if curl --silent --fail http://localhost:80/install.php | grep "Piwigo is already installed"; then
                    echo "Piwigo is already installed, skipping installation"
                    exit 0
                  fi
                  echo "Installing Piwigo..."
                  curl -X POST -d "${INSTALL_STRING}" http://localhost:80/install.php
                  if curl --silent --fail http://localhost:80/install.php | grep "Piwigo is already installed"; then
                    echo "Piwigo is already installed, skipping installation"
                    exit 0
                  fi
                  exit 1
      initContainers:
      {{- include "ix.v1.common.app.mariadbWait" (dict "name" "mariadb-wait"
                                                       "secretName" "mariadb-creds") | nindent 8 }}
{{- end -}}
