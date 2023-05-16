{{- define "gluetun.hidemyass.openvpn.env" -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverNames")) -}}
  {{- include "gluetun.openvpn.creds.required" $ -}}
{{- end -}}

{{- define "gluetun.hidemyass.wireguard.env" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
