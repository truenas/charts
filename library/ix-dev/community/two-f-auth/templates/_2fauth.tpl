{{- define "twofauth.workload" -}}
workload:
  twofauth:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.twofauthNetwork.hostNetwork }}
      containers:
        twofauth:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.twofauthRunAs.user }}
            runAsGroup: {{ .Values.twofauthRunAs.group }}
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: twofauth-creds
            - configMapRef:
                name: twofauth-config
          {{ with .Values.twofauthConfig.additionalEnvs }}
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
              port: 8000
              path: /infos
            readiness:
              enabled: true
              type: http
              port: 8000
              path: /infos
            startup:
              enabled: true
              type: http
              port: 8000
              path: /infos
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.twofauthRunAs.user
                                                        "GID" .Values.twofauthRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{- end -}}
