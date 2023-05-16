{{- define "gluetun.configs.openvpn.env" -}}
  {{- with .Values.gluetunConfig.openvpnKey }}
OPENVPN_KEY: {{ . }}
  {{- end }}
  {{- with .Values.gluetunConfig.openvpnCert }}
OPENVPN_CERT: {{ . }}
  {{- end }}
  {{- with .Values.gluetunConfig.openvpnUser }}
OPENVPN_USER: {{ . }}
  {{- end }}
  {{- with .Values.gluetunConfig.openvpnPassword }}
OPENVPN_PASSWORD: {{ . }}
  {{- end }}
{{- end -}}
