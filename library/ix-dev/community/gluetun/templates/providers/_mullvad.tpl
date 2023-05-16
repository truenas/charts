{{/* https://github.com/qdm12/gluetun/wiki/Mullvad */}}
{{- define "gluetun.mullvad.openvpn.validation" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "openvpnUser")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverRegions"
                                                            "serverNames")) -}}
{{- end -}}

{{- define "gluetun.mullvad.wireguard.validation" -}}
  {{- include "gluetun.options.required" (dict
                                          "rootCtx" $
                                          "options" (list
                                                    "wireguardPrivateKey"
                                                    "wireguardAddresses")) -}}
  {{- include "gluetun.unsupported.server.options" (dict
                                                  "rootCtx" $
                                                  "options" (list
                                                            "serverRegions"
                                                            "serverNames")) -}}
{{- end -}}
