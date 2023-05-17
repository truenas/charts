{{/* https://github.com/qdm12/gluetun/wiki/Windscribe */}}
{{- define "gluetun.windscribe.openvpn.validation" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "openvpnUser"
                                                    "openvpnPassword")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverCountries"
                                                            "serverNames")) -}}
{{- end -}}

{{- define "gluetun.windscribe.wireguard.validation" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "wireguardPrivateKey"
                                                    "wireguardAddresses")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverCountries"
                                                            "serverNames")) -}}
{{- end -}}
