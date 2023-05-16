{{- define "gluetun.configs.wireguard.env" -}}
  {{- if not .Values.gluetunConfig.wireguardPrivateKey -}}
    {{- fail (printf "Gluetun - Expected non empty [Wireguard Private Key] on [%v] provider and [Wireguard] Type" .Values.gluetunConfig.provider) -}}
  {{- end -}}
  {{- if not .Values.gluetunConfig.wireguardPresharedKey -}}
    {{- fail (printf "Gluetun - Expected non empty [Wireguard Preshared Key] on [%v] provider and [Wireguard] Type" .Values.gluetunConfig.provider) -}}
  {{- end -}}
  {{- if not .Values.gluetunConfig.wireguardAddresses -}}
    {{- fail (printf "Gluetun - Expected non empty [Wireguard Addresses] on [%v] provider and [Wireguard] Type" .Values.gluetunConfig.provider) -}}
  {{- end }}
WIREGUARD_PRIVATE_KEY: {{ .Values.gluetunConfig.wireguardPrivateKey }}
WIREGUARD_PRESHARED_KEY: {{ .Values.gluetunConfig.wireguardPresharedKey }}
WIREGUARD_ADDRESSES: {{ join "," .Values.gluetunConfig.wireguardAddresses }}
{{- end -}}
