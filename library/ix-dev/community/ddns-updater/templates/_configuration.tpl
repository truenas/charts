{{- define "ddns.configuration" -}}
{{- include "ddns.validation" $ }}

configmap:
  ddns-config:
    enabled: true
    data:
      PERIOD: {{ .Values.ddnsConfig.period | quote }}
      HTTP_TIMEOUT: {{ .Values.ddnsConfig.httpTimeout | quote }}
      BACKUP_PERIOD: {{ .Values.ddnsConfig.backupPeriod | quote }}
      UPDATE_COOLDOWN_PERIOD: {{ .Values.ddnsConfig.updateCooldownPeriod | quote }}
      PUBLICIP_DNS_TIMEOUT: {{ .Values.ddnsConfig.publicIpDnsTimeout | quote }}
      PUBLICIP_DNS_PROVIDERS: {{ join "," .Values.ddnsConfig.publicIpDnsProviders | quote }}
{{- end -}}

{{- define "ddns.validation" -}}
  {{- if not .Values.ddnsConfig.publicIpDnsProviders -}}
    {{- fail "DDNS Updater - Expected non-empty [Public IP DNS Providers]" -}}
  {{- end -}}
  {{- if (mustHas "all" .Values.ddnsConfig.publicIpDnsProviders) -}}
    {{- if ne (len .Values.ddnsConfig.publicIpDnsProviders) 1 -}}
      {{- fail "DDNS Updater - [Public IP DNS Providers] cannot contain other DNS Providers when [all] is selected" -}}
    {{- end -}}
  {{- end -}}
  {{- $publicIpDnsProviders := (list "google" "cloudflare" "all") -}}
  {{- range .Values.ddnsConfig.publicIpDnsProviders -}}
    {{- if not (mustHas . $publicIpDnsProviders) -}}
      {{- fail (printf "DDNS Updater - [Public IP DNS Providers] valid values are [%v], but got [%v]" (join ", " $publicIpDnsProviders) .) -}}
    {{- end -}}
  {{- end -}}


{{- end -}}
