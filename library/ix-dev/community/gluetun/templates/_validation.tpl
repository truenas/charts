{{- define "gluetun.validation" -}}
  {{- $providers := (list "custom" "airvpn" "cyberghost" "expressvpn"
                          "fastestvpn" "hidemyass" "ipvanish") -}}
  {{- if not (mustHas .Values.gluetunConfig.provider $providers) -}}
    {{- fail (printf "Gluetun - Expected [Provider] to be one of [%v], but got [%v]" (join ", " $providers) .Values.gluetunConfig.provider) -}}
  {{- end -}}

  {{- $types := (list "openvpn" "wireguard") -}}
  {{- if not (mustHas .Values.gluetunConfig.type $types) -}}
    {{- fail (printf "Gluetun - Expected [Type] to be one of [%v], but got [%v]" (join ", " $providers) .Values.gluetunConfig.type) -}}
  {{- end -}}
{{- end -}}

{{/* Included by providers that require OpenVPN credentials */}}
{{- define "gluetun.openvpn.creds.required" -}}
  {{- if not .Values.gluetunConfig.openvpnUser -}}
    {{- fail (printf "Gluetun - Provider [%v] requires [User] on type [%v]." .Values.gluetunConfig.provider .Values.gluetunConfig.type) -}}
  {{- end -}}
  {{- if not .Values.gluetunConfig.openvpnPassword -}}
    {{- fail (printf "Gluetun - Provider [%v] requires [Password] on type [%v]." .Values.gluetunConfig.provider .Values.gluetunConfig.type) -}}
  {{- end -}}
{{- end -}}

{{/* Included by providers that do not support one the the 2 types */}}
{{- define "gluetun.unsupported.type" -}}
  {{- fail (printf "Gluetun - Provider [%v] does not support type of [%v]." .Values.gluetunConfig.provider .Values.gluetunConfig.type) -}}
{{- end -}}

{{/* Inluded by providers that do not support all the server options */}}
{{- define "gluetun.unsupported.server.options" -}}
  {{- $options := .options -}}
  {{- $rootCtx := .rootCtx -}}

  {{- range $opt := $options -}}
    {{- if (get $rootCtx.Values.gluetunConfig $opt) -}}
      {{- fail (printf "Gluetun - Provider [%v] does not support [%v] option." $rootCtx.Values.gluetunConfig.provider (title $opt)) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
