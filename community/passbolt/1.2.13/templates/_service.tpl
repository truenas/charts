{{- define "passbolt.service" -}}
{{- $port := 8080 -}}
{{- if .Values.passboltNetwork.certificateID -}}
  {{- $port = 4433 -}}
{{- end }}
service:
  passbolt:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: passbolt
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.passboltNetwork.webPort }}
        nodePort: {{ .Values.passboltNetwork.webPort }}
        targetPort: {{ $port }}
        targetSelector: passbolt
  mariadb:
    enabled: true
    type: ClusterIP
    targetSelector: mariadb
    ports:
      mariadb:
        enabled: true
        primary: true
        port: 3306
        targetPort: 3306
        targetSelector: mariadb
{{- end -}}
