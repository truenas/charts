{{/* https://github.com/qdm12/gluetun/wiki/ExpressVPN */}}
{{- define "gluetun.expressvpn.openvpn.validation" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "openvpnUser"
                                                    "openvpnPassword")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                    "rootCtx" $
                                                    "options" (list
                                                              "serverRegions"
                                                              "serverNames")) -}}
{{- end -}}

{{- define "gluetun.expressvpn.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
