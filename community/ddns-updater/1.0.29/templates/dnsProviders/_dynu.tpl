{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/dynu.md */}}
{{- define "ddns.config.dynu" -}}
  {{- $item := .item }}
username: {{ $item.dynuUsername | required "DDNS Updater - Expected non-empty [Username] for Dynu provider" }}
password: {{ $item.dynuPassword | required "DDNS Updater - Expected non-empty [Password] for Dynu provider" }}
{{- if $item.dynuGroup }}
group: {{ $item.dynuGroup }}
{{- end }}
provider_ip: {{ $item.dynuProviderIP | default false }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: dynu            - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      dynuUsername: username    - Required
      dynuPassword: password    - Required
      dynuGroup: group          - Optional
      dynuProviderIP: true      - Required - Valid values (true/false)
*/}}
