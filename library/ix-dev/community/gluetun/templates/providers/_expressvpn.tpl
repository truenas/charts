{{/* https://github.com/qdm12/gluetun/wiki/ExpressVPN */}}
{{- define "gluetun.expressvpn.openvpn.env" -}}
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

{{- define "gluetun.expressvpn.wireguard.env" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
