{{- define "gluetun.validation" -}}
  {{- $providers := (list "custom" "airvpn") -}}
  {{- if not (mustHas .Values.gluetunConfig.provider $providers) -}}
    {{- fail (printf "Gluetun - Expected [Provider] to be one of [%v], but got [%v]" (join ", " $providers) .Values.gluetunConfig.provider) -}}
  {{- end -}}

  {{- $types := (list "openvpn" "wireguard") -}}
  {{- if not (mustHas .Values.gluetunConfig.type $types) -}}
    {{- fail (printf "Gluetun - Expected [Type] to be one of [%v], but got [%v]" (join ", " $providers) .Values.gluetunConfig.type) -}}
  {{- end -}}

{{- end -}}
