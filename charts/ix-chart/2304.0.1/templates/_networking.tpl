{{/*
DNS Configuration
*/}}
{{- define "dnsConfiguration" }}
dnsPolicy: {{ .Values.dnsPolicy }}
{{- if .Values.dnsConfig }}
dnsConfig:
  {{- toYaml .Values.dnsConfig | nindent 2 }}
{{- end }}
{{- end }}


{{/*
Get configuration for host network
*/}}
{{- define "hostNetworkingConfiguration" -}}
{{- $host := default false .Values.hostNetwork -}}
{{- if or .Values.externalInterfaces (eq $host false) -}}
{{- print "false" -}}
{{- else -}}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/* Validate portal port */}}
{{- if .Values.enableUIPortal }}
  {{- if and (not .Values.hostNetwork) (lt .Values.portalDetails.port 9000) }}
    {{- fail (printf "Port (%d) is too low. Minimum allowed port is 9000." .Values.portalDetails.port) }}
  {{- end }}
{{- end }}
