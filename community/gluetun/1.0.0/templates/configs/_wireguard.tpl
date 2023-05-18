{{- define "gluetun.configs.wireguard.env" -}}
  {{- with .Values.gluetunConfig.wireguardPrivateKey }}
WIREGUARD_PRIVATE_KEY: {{ . }}
  {{- end }}
  {{- with .Values.gluetunConfig.wireguardPresharedKey }}
WIREGUARD_PRESHARED_KEY: {{ . }}
  {{- end }}
  {{- with .Values.gluetunConfig.wireguardPublicKey }}
WIREGUARD_PUBLIC_KEY: {{ . }}
  {{- end }}
  {{- with .Values.gluetunConfig.wireguardAddresses }}
WIREGUARD_ADDRESSES: {{ join "," . }}
  {{- end }}
  {{- with .Values.gluetunConfig.vpnEndpointIP }}
VPN_ENDPOINT_IP: {{ . }}
  {{- end }}
  {{- with .Values.gluetunConfig.vpnEndpointPort }}
VPN_ENDPOINT_PORT: {{ . | quote }}
  {{- end }}
{{- end -}}
