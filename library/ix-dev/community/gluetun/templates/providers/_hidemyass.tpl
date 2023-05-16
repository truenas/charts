{{/* https://github.com/qdm12/gluetun/wiki/Hidemyass */}}
{{- define "gluetun.hidemyass.openvpn.env" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "openvpnUser"
                                                    "openvpnPassword")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                    "rootCtx" $
                                                    "options" (list
                                                              "serverNames")) -}}
{{- end -}}

{{- define "gluetun.hidemyass.wireguard.env" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
