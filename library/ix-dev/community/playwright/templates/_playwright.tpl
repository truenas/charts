{{- define "playwright.workload" -}}
workload:
  playwright:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.playwrightNetwork.hostNetwork }}
      containers:
        playwright:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.playwrightRunAs.user }}
            runAsGroup: {{ .Values.playwrightRunAs.group }}
            readOnlyRootFilesystem: false
          workingDir: /project
          command: npx
          args:
            - -y
            - playwright
            - test
            - --ui-host=0.0.0.0
            - "--ui-port={{ .Values.playwrightNetwork.webPort }}"
          env:
          {{ with .Values.playwrightConfig.additionalEnvs }}
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
              port: "{{ .Values.playwrightNetwork.webPort }}"
              path: /
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.playwrightNetwork.webPort }}"
              path: /
            startup:
              enabled: true
              type: http
              port: "{{ .Values.playwrightNetwork.webPort }}"
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.playwrightRunAs.user
                                                        "GID" .Values.playwrightRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
