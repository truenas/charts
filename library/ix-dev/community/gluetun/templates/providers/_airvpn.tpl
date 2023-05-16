{{/* https://github.com/qdm12/gluetun/wiki/AirVPN */}}
{{- define "gluetun.airvpn.openvpn.env" -}}
  {{/* Continue */}}
{{- end -}}

{{- define "gluetun.airvpn.wireguard.env" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "wireguardPrivateKey"
                                                    "wireguardPresharedKey"
                                                    "wireguardAddresses")) -}}
{{- end -}}
