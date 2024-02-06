{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/netcup.md */}}
{{- define "ddns.config.netcup" -}}
  {{- $item := .item }}
api_key: {{ $item.netcupApiKey | required "DDNS Updater - Expected non-empty [Api Key] for netcup provider" }}
password: {{ $item.netcupPassword | required "DDNS Updater - Expected non-empty [Password] for netcup provider" }}
customer_number: {{ $item.netcupCustomerNumber | required "DDNS Updater - Expected non-empty [Customer Number] for netcup provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: netcup            - Required
      domain: "example.com"       - Required
      host: "@"                   - Required - Valid value ("@" or subdomain)
      ipVersion: ""               - Required - Valid values (ipv4/ipv6/"")
      netcupApiKey: pass          - Required
      netcupPassword: pass        - Required
      netcupCustomerNumber: 12345 - Required
*/}}
