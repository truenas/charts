{{/* https://github.com/qdm12/gluetun/wiki/Cyberghost */}}
{{- define "gluetun.cyberghost.openvpn.validation" -}}
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

{{- define "gluetun.cyberghost.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
