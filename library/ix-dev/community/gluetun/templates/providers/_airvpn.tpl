{{/* https://github.com/qdm12/gluetun/wiki/AirVPN */}}
{{- define "gluetun.airvpn.openvpn.validation" -}}
  {{/* Continue */}}
{{- end -}}

{{- define "gluetun.airvpn.wireguard.validation" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "wireguardPrivateKey"
                                                    "wireguardPresharedKey"
                                                    "wireguardAddresses")) -}}
{{- end -}}
