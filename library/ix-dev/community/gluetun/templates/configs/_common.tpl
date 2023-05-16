{{- define "gluetun.configs.common.env" -}}
  {{- with .Values.gluetunConfig.serverCountries }}
SERVER_COUNTRIES: {{ join "," }}
  {{- end }}
  {{- with .Values.gluetunConfig.serverRegions }}
SERVER_REGIONS: {{ join "," }}
  {{- end }}
  {{- with .Values.gluetunConfig.serverCities }}
SERVER_CITIES: {{ join "," }}
  {{- end }}
  {{- with .Values.gluetunConfig.serverHostnames }}
SERVER_HOSTNAMES: {{ join "," }}
  {{- end }}
{{- end -}}
