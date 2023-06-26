{{- define "filebrowser.workload" -}}
{{- $configBasePath := "/config" }}
workload:
  filebrowser:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.filebrowserNetwork.hostNetwork }}
      containers:
        filebrowser:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.filebrowserRunAs.user }}
            runAsGroup: {{ .Values.filebrowserRunAs.group }}
          args:
            - --config
            - {{ $configBasePath }}/filebrowser.json
            - --database
            - {{ $configBasePath }}/filebrowser.db
            - --port
            - "{{ .Values.filebrowserNetwork.webPort }}"
            - --address
            - "0.0.0.0"
            - --root
            - /data
          {{ with .Values.filebrowserConfig.additionalEnvs }}
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
              port: "{{ .Values.filebrowserNetwork.webPort }}"
              path: /health
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.filebrowserNetwork.webPort }}"
              path: /health
            startup:
              enabled: true
              type: http
              port: "{{ .Values.filebrowserNetwork.webPort }}"
              path: /health
      initContainers:
        {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                          "UID" .Values.filebrowserRunAs.user
                                                          "GID" .Values.filebrowserRunAs.group
                                                          "mode" "check"
                                                          "type" "init") | nindent 8 }}
        02-init-config:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.filebrowserRunAs.user }}
            runAsGroup: {{ .Values.filebrowserRunAs.group }}
          # Creating the config file if it doesn't exist
          # This will make the container to log
          # "Using config file: {{ $configBasePath }}/filebrowser.json"
          # on startup, so users know where the config is, in case they need it.
          # Arguments will take precedence over the config file always.
          # (Like the port, paths, etc we set above.)
          command:
            - /bin/sh
            - -c
            - |
              if [ ! -f {{ $configBasePath }}/filebrowser.json ]; then
                echo "Creating an empty config file"
                echo '{}' > {{ $configBasePath }}/filebrowser.json
              fi
{{- end -}}
