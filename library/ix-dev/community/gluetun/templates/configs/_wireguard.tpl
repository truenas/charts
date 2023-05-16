{{- define "gluetun.configs.wireguard.env" -}}
  {{- with .Values.gluetunConfig.wireguardPrivateKey }}
WIREGUARD_PRIVATE_KEY: {{ . }}
  {{- end }}
  {{- with .Values.gluetunConfig.wireguardPresharedKey }}
WIREGUARD_PRESHARED_KEY: {{ . }}
  {{- end }}
  {{- with .Values.gluetunConfig.wireguardAddresses }}
WIREGUARD_ADDRESSES: {{ join "," . }}
  {{- end }}
{{- end -}}
