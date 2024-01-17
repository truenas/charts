{{- define "home-assistant.workload" -}}
workload:
  home-assistant:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.haNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.haID.group }}
      containers:
        home-assistant:
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
                - NET_BIND_SERVICE
                - NET_RAW
          fixedEnv:
            PUID: {{ .Values.haID.user }}
          {{ with .Values.haConfig.additionalEnvs }}
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
              path: /manifest.json
              port: 8123
            readiness:
              enabled: true
              type: http
              path: /manifest.json
              port: 8123
            startup:
              enabled: true
              type: http
              path: /manifest.json
              port: 8123
      initContainers:
        01-init-config:
          enabled: true
          type: init
          imageSelector: bashImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          command: bash
          args:
            - -c
            - |
              config="/config/configuration.yaml"
              default="/default/init"
              if [ -f "$config" ]; then
                echo "File [$config] exists"
              else
                echo "File [$config] does NOT exist. Creating..."
                cp "$default/configuration.default" "$config"
              fi
              if grep -q "recorder:" "$config"; then
                echo "Section [recorder] exists in [$config]"
                exit 0
              fi
              echo "Section [recorder] does NOT exist in [$config]. Appedning..."
              cat "$default/recorder.default" >> "$config"
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
