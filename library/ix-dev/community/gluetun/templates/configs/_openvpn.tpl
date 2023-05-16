{{- define "gluetun.configs.openvpn.env" -}}
  {{- with .Values.gluetunConfig.openvpnKey }}
OPENVPN_KEY: {{ . }}
  {{- end }}
  {{- with .Values.gluetunConfig.openvpnCert }}
OPENVPN_CERT: {{ . }}
  {{- end }}
{{- end -}}
