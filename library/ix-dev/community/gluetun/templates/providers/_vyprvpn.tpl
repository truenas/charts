{{/* https://github.com/qdm12/gluetun/wiki/VyprVPN */}}
{{- define "gluetun.vyprvpn.openvpn.validation" -}}
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

{{- define "gluetun.vyprvpn.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
