{{/* https://github.com/qdm12/gluetun/wiki/WeVPN */}}
{{- define "gluetun.wevpn.openvpn.validation" -}}
  {{- $req := list -}}

  {{- if eq .Values.gluetunConfig.openvpnCertKeyMethod "file" -}}
    {{- $req = (list "openvpnKeyHostPath") -}}
  {{- else if eq .Values.gluetunConfig.openvpnCertKeyMethod "content" -}}
    {{- $req = (list "openvpnKey") -}}
  {{- else -}}
    {{- include "gluetun.certkey.required.error" $ -}}
  {{- end -}}

  {{- $req = concat $req (list "openvpnUser" "openvpnPassword") -}}

  {{- $unsup := (list "serverRegions" "serverCountries" "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}

{{- define "gluetun.wevpn.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
