{{/* https://github.com/qdm12/gluetun/wiki/NordVPN */}}
{{- define "gluetun.nordvpn.openvpn.validation" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "openvpnUser"
                                                    "openvpnPassword")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverCountries"
                                                            "serverCities"
                                                            "serverNames")) -}}
{{- end -}}

{{- define "gluetun.nordvpn.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
