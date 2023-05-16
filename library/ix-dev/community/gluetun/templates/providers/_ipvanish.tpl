{{/* https://github.com/qdm12/gluetun/wiki/IPVanish */}}
{{- define "gluetun.ipvanish.openvpn.env" -}}
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

{{- define "gluetun.ipvanish.wireguard.env" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
