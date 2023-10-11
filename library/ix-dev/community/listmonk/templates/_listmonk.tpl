{{- define "listmonk.workload" -}}
workload:
  listmonk:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.listmonkNetwork.hostNetwork }}
      containers:
        listmonk:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.listmonkRunAs.user }}
            runAsGroup: {{ .Values.listmonkRunAs.group }}
          envFrom:
            - secretRef:
                name: listmonk-creds
          {{ with .Values.listmonkConfig.additionalEnvs }}
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
              port: {{ .Values.listmonkNetwork.webPort }}
              path: /health
            readiness:
              enabled: true
              type: http
              port: {{ .Values.listmonkNetwork.webPort }}
              path: /health
            startup:
              enabled: true
              type: http
              port: {{ .Values.listmonkNetwork.webPort }}
              path: /health
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "01-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
        02-db:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.listmonkRunAs.user }}
            runAsGroup: {{ .Values.listmonkRunAs.group }}
          envFrom:
            - secretRef:
                name: listmonk-creds
          command:
            - /listmonk/listmonk
          args:
          {{- if .Release.IsInstall }}
            - --install
          {{- else }}
            - --upgrade
          {{- end }}
            - --yes
{{- end -}}
