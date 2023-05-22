{{- define "gluetun.configs.openvpn.env" -}}
  {{- with .Values.gluetunConfig.openvpnKey }}
OPENVPN_KEY: {{ . | quote }}
  {{- end }}
  {{- with .Values.gluetunConfig.openvpnCert }}
OPENVPN_CERT: {{ . | quote }}
  {{- end }}
  {{- with .Values.gluetunConfig.openvpnUser }}
OPENVPN_USER: {{ . | quote }}
  {{- end }}
  {{- with .Values.gluetunConfig.openvpnPassword }}
OPENVPN_PASSWORD: {{ . | quote }}
  {{- end }}
  {{- with .Values.gluetunConfig.openvpnKeyPassphrase }}
OPENVPN_KEY_PASSPHRASE: {{ . | quote }}
  {{- end }}
  {{- if .Values.gluetunConfig.openvpnCustomConfigHostPath }}
OPENVPN_CUSTOM_CONFIG: /gluetun/custom.conf
  {{- end }}
{{- end -}}
