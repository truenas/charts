{{- define "gluetun.airvpn.openvpn.env" -}}
  {{- include "gluetun.configs.openvpn.env" $ -}}
{{- end -}}

{{- define "gluetun.airvpn.wireguard.env" -}}
  {{- include "gluetun.configs.wireguard.env" $ -}}
{{- end -}}
