{{/* https://github.com/qdm12/gluetun/wiki/VPN-Secure */}}
{{- define "gluetun.vpnsecure.openvpn.validation" -}}
  {{- $req := list -}}

  {{- if eq .Values.gluetunConfig.openvpnCertKeyMethod "file" -}}
    {{- $req = (list "openvpnCertHostPath" "openvpnKeyHostPath") -}}
  {{- else if eq .Values.gluetunConfig.openvpnCertKeyMethod "content" -}}
    {{- $req = (list "openvpnCert" "openvpnKey") -}}
  {{- else -}}
    {{- include "gluetun.certkey.required.error" $ -}}
  {{- end -}}

  {{- $req = concat $req (list "openvpnKeyPassphrase") -}}

  {{- $unsup := (list "serverCountries" "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}

{{- define "gluetun.vpnsecure.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
