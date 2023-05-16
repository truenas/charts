{{- define "gluetun.ipvanish.openvpn.env" -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverRegions"
                                                            "serverNames")) -}}
  {{- include "gluetun.openvpn.creds.required" $ -}}
{{- end -}}

{{- define "gluetun.ipvanish.wireguard.env" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
