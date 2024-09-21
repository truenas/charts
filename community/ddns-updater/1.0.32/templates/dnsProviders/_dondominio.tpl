{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/dondominio.md */}}
{{- define "ddns.config.dondominio" -}}
  {{- $item := .item }}
username: {{ $item.donDominioUsername | required "DDNS Updater - Expected non-empty [Username] for Don Dominio provider" }}
password: {{ $item.donDominioPassword | required "DDNS Updater - Expected non-empty [Password] for Don Dominio provider" }}
name: {{ $item.donDominioName | required "DDNS Updater - Expected non-empty [Name] for Don Dominio provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: dondominio      - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      donDominioUsername: user  - Required
      donDominioPassword: pass  - Required
      donDominioName: name      - Required
*/}}
