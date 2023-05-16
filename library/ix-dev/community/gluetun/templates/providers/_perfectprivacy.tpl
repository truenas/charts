{{/* https://github.com/qdm12/gluetun/wiki/Perfect-privacy */}}
{{- define "gluetun.perfect privacy.openvpn.validation" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "openvpnUser"
                                                    "openvpnPassword")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverCountries"
                                                            "serverRegions"
                                                            "serverHostnames"
                                                            "serverNames")) -}}
{{- end -}}

{{- define "gluetun.perfect privacy.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
