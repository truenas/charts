{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/ddnss.md */}}
{{- define "ddns.config.ddnss" -}}
  {{- $item := .item }}
username: {{ $item.ddnssUsername | required "DDNS Updater - Expected non-empty [Username] for DDNSS provider" }}
password: {{ $item.ddnssPassword | required "DDNS Updater - Expected non-empty [Password] for DDNSS provider" }}
provider_ip: {{ $item.ddnssProviderIP }}
{{- if not $item.ddnssProviderIP }}
dual_stack: {{ $item.ddnssDualStack | default false }}
{{- end -}}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: ddnss           - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      ddnssUsername: user       - Required
      ddnssPassword: password   - Required
      ddnssProviderIP: true     - Required - Valid values (true/false)
      ddnssDualStack: false     - Optional - Valid values (true/false)
*/}}
