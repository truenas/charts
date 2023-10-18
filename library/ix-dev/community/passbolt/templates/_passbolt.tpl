{{- define "passbolt.workload" -}}
workload:
  passbolt:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        passbolt:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 33
            runAsGroup: 33
            capabilities:
              add:
                - NET_BIND_SERVICE
          envFrom:
            - secretRef:
                name: passbolt-creds
            - configMapRef:
                name: passbolt-config
          {{ with .Values.passboltConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{- $port := 8080 -}}
            {{- if .Values.passboltNetwork.certificateID -}}
              {{- $port = 4433 -}}
            {{- end }}
            liveness:
              enabled: true
              type: tcp
              port: {{ $port }}
            readiness:
              enabled: true
              type: tcp
              port: {{ $port }}
            startup:
              enabled: true
              type: tcp
              port: {{ $port }}
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 33
                                                        "GID" 33
                                                        "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.mariadbWait" (dict "name" "mariadb-wait"
                                                       "secretName" "mariadb-creds") | nindent 8 }}
{{- end -}}
