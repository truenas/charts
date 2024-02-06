{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/zoneedit.md */}}
{{- define "ddns.config.zoneedit" -}}
  {{- $item := .item }}
username: {{ $item.zoneeditUsername | required "DDNS Updater - Expected non-empty [Username] for zoneedit provider" }}
token: {{ $item.zoneeditToken | required "DDNS Updater - Expected non-empty [Token] for zoneedit provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: zoneedit       - Required
      domain: "example.com"    - Required
      host: "@"                - Required - Valid value ("@" or subdomain)
      ipVersion: ""            - Required - Valid values (ipv4/ipv6/"")
      zoneeditUsername: pass   - Required
      zoneeditToken: pass      - Required
*/}}
