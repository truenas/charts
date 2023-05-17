{{/* https://github.com/qdm12/gluetun/wiki/WeVPN */}}
{{- define "gluetun.wevpn.openvpn.validation" -}}
  {{/* Cert and Key Required */}}
  {{- if eq .Values.gluetunConfig.openvpnCertKeyMethod "file" -}}
    {{- include "gluetun.options.required" (dict "rootCtx" $
                                                  "options" (list "openvpnKeyHostPath")) -}}
  {{- else if eq .Values.gluetunConfig.openvpnCertKeyMethod "content" -}}
    {{- include "gluetun.options.required" (dict "rootCtx" $
                                                  "options" (list "openvpnKey")) -}}
  {{- else -}}
    {{- include "gluetun.certkey.required.error" $ -}}
  {{- end -}}
  {{/* Required */}}
  {{- include "gluetun.options.required" (dict "rootCtx" $
                                                "options" (list
                                                          "openvpnUser"
                                                          "openvpnPassword")) -}}

  {{/* Unsupported */}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $
                                                          "options" (list
                                                                    "serverCountries"
                                                                    "serverRegions"
                                                                    "serverNames")) -}}
{{- end -}}

{{- define "gluetun.wevpn.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
