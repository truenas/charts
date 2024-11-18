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
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                    "UID" .Values.listmonkRunAs.user
                                                    "GID" .Values.listmonkRunAs.group
                                                    "mode" "check"
                                                    "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "02-postgres-wait"
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
            - /bin/sh
          args:
            - -c
            - |
              /listmonk/listmonk --install --idempotent --yes
              /listmonk/listmonk --upgrade --yes
{{- end -}}
