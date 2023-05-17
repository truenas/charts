{{/* https://github.com/qdm12/gluetun/wiki/VPN-Secure */}}
{{- define "gluetun.vpnsecure.openvpn.validation" -}}
  {{/* Cert and Key Required */}}
  {{- if eq .Values.gluetunConfig.openvpnCertKeyMethod "file" -}}
    {{- include "gluetun.options.required" (dict "rootCtx" $
                                                  "options" (list
                                                            "openvpnCertHostPath"
                                                            "openvpnKeyHostPath")) -}}
  {{- else if eq .Values.gluetunConfig.openvpnCertKeyMethod "content" -}}
    {{- include "gluetun.options.required" (dict "rootCtx" $
                                                  "options" (list
                                                            "openvpnCert"
                                                            "openvpnKey")) -}}
  {{- else -}}
    {{- include "gluetun.certkey.required.error" $ -}}
  {{- end -}}
  {{/* Required */}}
  {{- include "gluetun.options.required" (dict "rootCtx" $
                                                "options" (list
                                                          "openvpnKeyPassphrase")) -}}
  {{/* Unsupported */}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $
                                                          "options" (list
                                                                    "serverCountries"
                                                                    "serverNames")) -}}
{{- end -}}

{{- define "gluetun.vpnsecure.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
