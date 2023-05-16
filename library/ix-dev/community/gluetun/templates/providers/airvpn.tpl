{{- define "gluetun.airvpn.openvpn.env" -}}
  {{- include "gluetun.configs.openvpn.env" $ -}}
{{- end -}}

{{- define "gluetun.airvpn.wireguard.env" -}}
  {{- if not .Values.gluetunConfig.wireguardPrivateKey -}}
    {{- fail "Gluetun - Expected non empty [Wireguard Private Key] on [AirVPN] provider and [Wireguard] Type" -}}
  {{- end -}}
  {{- if not .Values.gluetunConfig.wireguardPresharedKey -}}
    {{- fail "Gluetun - Expected non empty [Wireguard Preshared Key] on [AirVPN] provider and [Wireguard] Type" -}}
  {{- end -}}
  {{- if not .Values.gluetunConfig.wireguardAddresses -}}
    {{- fail "Gluetun - Expected non empty [Wireguard Addresses] on [AirVPN] provider and [Wireguard] Type" -}}
  {{- end }}
WIREGUARD_PRIVATE_KEY: {{ .Values.gluetunConfig.wireguardPrivateKey }}
WIREGUARD_PRESHARED_KEY: {{ .Values.gluetunConfig.wireguardPresharedKey }}
WIREGUARD_ADDRESSES: {{ join "," .Values.gluetunConfig.wireguardAddresses }}
{{- end -}}
