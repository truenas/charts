{{/* https://github.com/qdm12/gluetun/wiki/AirVPN */}}
{{- define "gluetun.airvpn.openvpn.validation" -}}
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
{{- end -}}

{{- define "gluetun.airvpn.wireguard.validation" -}}
  {{/* Required */}}
  {{- include "gluetun.options.required" (dict "rootCtx" $
                                                "options" (list
                                                          "wireguardPrivateKey"
                                                          "wireguardPresharedKey"
                                                          "wireguardAddresses")) -}}
{{- end -}}
