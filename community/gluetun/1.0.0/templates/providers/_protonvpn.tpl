{{/* https://github.com/qdm12/gluetun/wiki/ProtonVPN */}}
{{- define "gluetun.protonvpn.openvpn.validation" -}}
  {{- $req := (list "openvpnUser" "openvpnPassword") -}}

  {{- $unsup := (list "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}

{{- define "gluetun.protonvpn.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
