{{/* https://github.com/qdm12/gluetun/wiki/AirVPN */}}
{{- define "gluetun.airvpn.openvpn.validation" -}}
  {{- $req := list -}}

  {{- if eq .Values.gluetunConfig.openvpnCertKeyMethod "file" -}}
    {{- $req = (list "openvpnCertHostPath" "openvpnKeyHostPath") -}}
  {{- else if eq .Values.gluetunConfig.openvpnCertKeyMethod "content" -}}
    {{- $req = (list "openvpnCert" "openvpnKey") -}}
  {{- else -}}
    {{- include "gluetun.certkey.required.error" $ -}}
  {{- end -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
{{- end -}}

{{- define "gluetun.airvpn.wireguard.validation" -}}
  {{- $req := (list "wireguardPrivateKey" "wireguardPresharedKey" "wireguardAddresses") -}}
  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
{{- end -}}
