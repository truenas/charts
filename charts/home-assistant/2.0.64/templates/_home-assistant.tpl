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
            privileged: {{ .Values.haConfig.allowDevices | default false }}
            allowPrivilegeEscalation: {{ .Values.haConfig.allowDevices | default false }}
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
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
          imageSelector: yqImage
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
          command: /default/init/script.sh
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
