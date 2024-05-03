{{- define "nextcloud.workload" -}}
workload:
  nextcloud:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      securityContext:
        fsGroup: 33
      containers:
        nextcloud:
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
                - NET_RAW
                - SETGID
                - SETUID
          envFrom:
            - secretRef:
                name: nextcloud-creds
          {{ with .Values.ncConfig.additionalEnvs }}
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
              port: 80
              path: /status.php
              httpHeaders:
                Host: localhost
            readiness:
              enabled: true
              type: http
              port: 80
              path: /status.php
              httpHeaders:
                Host: localhost
            startup:
              enabled: true
            {{- include "nextcloud.validate-commands" $ -}}
            {{- $cmds := .Values.ncConfig.commands | mustUniq -}}
            {{- if not $cmds }}
              type: http
              port: 80
              path: /status.php
              httpHeaders:
                Host: localhost
            {{- else }}
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  check_commands={{ join " " $cmds }}
                  for comm in $check_commands; do
                    if ! command -v $comm /dev/null 2>&1; then
                      echo "Command $comm not found"
                      exit 1
                    fi
                  done
            {{- end }}
          lifecycle:
            postStart:
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  echo "Installing {{ join " " $cmds }}..."
                  apt update && apt install -y --no-install-recommends \
                  {{ join " " $cmds }} || echo "Failed to install binary/binaries..."
                  echo "Finished."
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
{{- end -}}


{{- define "nextcloud.validate-commands" -}}
  {{- $allowedCommmads := list "ffmpeg" "smbclient" -}}

  {{- range $c := .Values.ncConfig.commands | mustUniq -}}
    {{- if not (mustHas $c $allowedCommmads) -}}
      {{- fail (printf "Nextcloud - Expected command to be one of [%s], but got [%s]" (join ", " $allowedCommmads) $c) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
