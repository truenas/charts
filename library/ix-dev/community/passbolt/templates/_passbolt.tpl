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
            readOnlyRootFilesystem: false
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
            {{- $protocol := "http" -}}
            {{- if .Values.passboltNetwork.certificateID -}}
              {{- $port = 4433 -}}
              {{- $protocol = "https" -}}
            {{- end }}
            liveness:
              enabled: true
              type: {{ $protocol }}
              port: {{ $port }}
              path: /healthcheck/status
            readiness:
              enabled: true
              type: {{ $protocol }}
              port: {{ $port }}
              path: /healthcheck/status
            startup:
              enabled: true
              type: {{ $protocol }}
              port: {{ $port }}
              path: /healthcheck/status
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 33
                                                        "GID" 33
                                                        "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.mariadbWait" (dict "name" "02-mariadb-wait"
                                                       "secretName" "mariadb-creds") | nindent 8 }}
      {{- if .Release.IsInstall }}
        03-init-user:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: 33
            runAsGroup: 33
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: passbolt-creds
            - configMapRef:
                name: passbolt-config
          command:
            - /bin/sh
            - -c
            - |
              /usr/share/php/passbolt/bin/cake passbolt register_user -r admin \
              -f {{ .Values.passboltConfig.adminFirstName }} \
              -l {{ .Values.passboltConfig.adminLastName }} \
              -u {{ .Values.passboltConfig.adminEmail }}
      {{- end -}}
{{- end -}}
