{{- define "gluetun.cyberghost.openvpn.env" -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverRegions"
                                                            "serverCities"
                                                            "serverNames")) -}}
  {{- include "gluetun.openvpn.creds.required" $ -}}
{{- end -}}

{{- define "gluetun.cyberghost.wireguard.env" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
