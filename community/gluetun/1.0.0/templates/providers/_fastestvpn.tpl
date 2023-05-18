{{/* https://github.com/qdm12/gluetun/wiki/FastestVPN */}}
{{- define "gluetun.fastestvpn.openvpn.validation" -}}
  {{- $req := (list "openvpnUser" "openvpnPassword") -}}

  {{- $unsup := (list "serverRegions" "serverCities" "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}

{{- define "gluetun.fastestvpn.wireguard.validation" -}}
  {{- include "gluetun.unsupported.type" $ -}}
{{- end -}}
