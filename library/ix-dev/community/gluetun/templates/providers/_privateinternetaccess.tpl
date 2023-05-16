{{/* https://github.com/qdm12/gluetun/wiki/Private-internet-access */}}
{{- define "gluetun.private internet access.openvpn.validation" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "openvpnUser"
                                                    "openvpnPassword")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverCities"
                                                            "serverCountries")) -}}
{{- end -}}

{{- define "gluetun.private internet access.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
