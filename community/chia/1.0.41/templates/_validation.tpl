{{- define "chia.validation" -}}

  {{- with $.Values.chiaConfig.service -}}

    {{- $allowedModes := list "farmer-only" "harvester" "\"\"" -}}
    {{- if not (mustHas . $allowedModes) -}}
      {{- fail (printf "Expected <service> to be one of [%s], but got [%s]" (join ", " $allowedModes) .) -}}
    {{- end -}}

  {{- end -}}

  {{- if eq $.Values.chiaConfig.service "harvester" -}}
    {{- $reqs := list "farmer_address" "farmer_port" "ca" -}}

    {{- range $key := $reqs -}}
      {{- if not (get $.Values.chiaConfig $key) -}}
        {{- fail (printf "Expected non-empty <%s> when <node_mode> is set to <harvester>" $key) -}}
      {{- end -}}
    {{- end -}}

  {{- end -}}
{{- end -}}
