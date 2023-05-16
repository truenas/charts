{{/* https://github.com/qdm12/gluetun/wiki/Cyberghost */}}
{{- define "gluetun.cyberghost.openvpn.env" -}}
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

{{- define "gluetun.cyberghost.wireguard.env" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
