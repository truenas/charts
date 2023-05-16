{{- define "gluetun.configs.common.env" -}}
  {{/*
    View available options per provider here
    https://raw.githubusercontent.com/qdm12/gluetun/master/internal/storage/servers.json
  */}}
  {{- with .Values.gluetunConfig.serverCountries }}
SERVER_COUNTRIES: {{ join "," . }}
  {{- end }}
  {{- with .Values.gluetunConfig.serverRegions }}
SERVER_REGIONS: {{ join "," . }}
  {{- end }}
  {{- with .Values.gluetunConfig.serverCities }}
SERVER_CITIES: {{ join "," . }}
  {{- end }}
  {{- with .Values.gluetunConfig.serverHostnames }}
SERVER_HOSTNAMES: {{ join "," . }}
  {{- end }}
{{- end -}}
