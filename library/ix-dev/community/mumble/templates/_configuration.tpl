{{- define "mumble.configuration" -}}

{{/* Configmaps */}}
configmap:
  mumble-config:
    enabled: true
    data:
      {{ if .Values.mumbleNetwork.certificateID }}
      MUMBLE_CONFIG_sslCert: /certs/public.crt
      MUMBLE_CONFIG_sslKey: /certs/private.key
      {{ end }}
      MUMBLE_CONFIG_database: /data/mumble-server.sqlite
      MUMBLE_CONFIG_port: {{ .Values.mumbleNetwork.serverPort | quote }}
      MUMBLE_CONFIG_welcometext: {{ .Values.mumbleConfig.welcomeText }}
      MUMBLE_CONFIG_users: {{ .Values.mumbleConfig.users | quote }}
      MUMBLE_CONFIG_ice: {{ printf "tcp -h 127.0.0.1 -p %v" .Values.mumbleNetwork.icePort }}
secret:
  mumble-secret:
    enabled: true
    data:
      MUMBLE_SUPERUSER_PASSWORD: {{ .Values.mumbleConfig.superUserPassword | quote }}
      MUMBLE_CONFIG_serverpassword: {{ .Values.mumbleConfig.serverPassword | quote }}
      MUMBLE_CONFIG_icesecretread: {{ .Values.mumbleConfig.iceSecretRead }}
      MUMBLE_CONFIG_icesecretwrite: {{ .Values.mumbleConfig.iceSecretWrite }}
{{- end -}}
