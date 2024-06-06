{{- define "tautulli.workload" -}}
workload:
  tautulli:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.tautulliNetwork.hostNetwork }}
      containers:
        tautulli:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.tautulliRunAs.user }}
            runAsGroup: {{ .Values.tautulliRunAs.group }}
          command:
            - python
            - Tautulli.py
          args:
            - --port
            - {{ .Values.tautulliNetwork.webPort | quote }}
            - --config
            - /config/config.ini
            - --datadir
            - /config
          {{ with .Values.tautulliConfig.additionalEnvs }}
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
              port: "{{ .Values.tautulliNetwork.webPort }}"
              path: /status
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.tautulliNetwork.webPort }}"
              path: /status
            startup:
              enabled: true
              type: http
              port: "{{ .Values.tautulliNetwork.webPort }}"
              path: /status
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.tautulliRunAs.user
                                                        "GID" .Values.tautulliRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
