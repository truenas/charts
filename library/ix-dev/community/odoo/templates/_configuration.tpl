{{- define "odoo.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "odoo" -}}
  {{- $dbName := "odoo" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "odooDbPass" $dbPass -}}
  {{- $_ := set .Values "odooDbHost" $dbHost -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

  {{/* xmlrpc* keys are deprecated and http* keys are used in their place */}}
  {{- $reservedKeys := (list  "data_dir" "addons_path" "http_enable" "http_interface"
                              "http_port"  "xmlrpc" "xmlrpc_port" "xmlrpc_interface"
                              "db_port" "db_host" "db_name" "db_user" "db_sslmode"
                              "db_password") -}}
  {{- $userKeys := list -}}
  odoo-config:
    enabled: true
    data:
      odoo.conf: |
        [options]
        ; Paths
        data_dir = /var/lib/odoo
        addons_path = /mnt/extra-addons
        ; Network Details
        http_enable = True
        http_port = {{ .Values.odooNetwork.webPort }}
        ; Database Details
        db_port = 5432
        db_host = {{ $dbHost }}
        db_name = {{ $dbName }}
        db_user = {{ $dbUser }}
        db_sslmode = disable
        db_password = {{ $dbPass }}
        {{- range $opt := .Values.odooConfig.additionalConf -}}
          {{- if (mustHas $opt.key $reservedKeys) -}}
            {{- fail (printf "Odoo - Key [%v] is not allowed to be modified") -}}
          {{- end -}}
          {{- $userKeys = mustAppend $userKeys $opt.key -}}
          {{- printf "%s = %s" $opt.key $opt.value | nindent 8 -}}
        {{- end -}}
  {{- if not (deepEqual $userKeys (uniq $userKeys)) -}}
    {{- fail (printf "Odoo - Additional configuration keys must be unique, but got [%v]" (join ", " $userKeys)) -}}
  {{- end -}}
{{- end -}}
