{{/* https://github.com/qdm12/gluetun/wiki/FastestVPN */}}
{{- define "gluetun.fastestvpn.openvpn.env" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "openvpnUser"
                                                    "openvpnPassword")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                    "rootCtx" $
                                                    "options" (list
                                                              "serverRegions"
                                                              "serverCities"
                                                              "serverNames")) -}}
{{- end -}}

{{- define "gluetun.fastestvpn.wireguard.env" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
