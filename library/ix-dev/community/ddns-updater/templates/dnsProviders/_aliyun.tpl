{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/aliyun.md */}}
{{- define "ddns.config.aliyun" -}}
  {{- $item := .item }}
access_key_id: {{ $item.aliyunAccessKey | required "DDNS Updater - Expected non-empty [Access Key] for Aliyun provider" }}
access_secret: {{ $item.aliyunSecret | required "DDNS Updater - Expected non-empty [Secret] for Aliyun provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: aliyun          - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      aliyunAccessKey: key      - Required
      aliyunSecret: secret      - Required
*/}}
