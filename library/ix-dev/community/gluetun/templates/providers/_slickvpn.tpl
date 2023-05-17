{{/* https://github.com/qdm12/gluetun/wiki/SlickVPN */}}
{{- define "gluetun.slickvpn.openvpn.validation" -}}
  {{- $req := list -}}

  {{- if eq .Values.gluetunConfig.openvpnCertKeyMethod "file" -}}
    {{- $req = (list "openvpnCertHostPath" "openvpnKeyHostPath") -}}
  {{- else if eq .Values.gluetunConfig.openvpnCertKeyMethod "content" -}}
    {{- $req = (list "openvpnCert" "openvpnKey") -}}
  {{- else -}}
    {{- include "gluetun.certkey.required.error" $ -}}
  {{- end -}}

  {{- $req = concat $req (list "openvpnUser" "openvpnPassword") -}}

  {{- $unsup := (list "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}

{{- define "gluetun.slickvpn.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
