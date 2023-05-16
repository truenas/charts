{{/* https://github.com/qdm12/gluetun/wiki/PrivateVPN */}}
{{- define "gluetun.privatevpn.openvpn.validation" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "openvpnUser"
                                                    "openvpnPassword")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverRegions"
                                                            "serverHostnames"
                                                            "serverNames")) -}}
{{- end -}}

{{- define "gluetun.privatevpn.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
