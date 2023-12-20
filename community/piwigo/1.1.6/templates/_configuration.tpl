{{- define "piwigo.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-mariadb" $fullname) -}}
  {{- $dbUser := "piwigo" -}}
  {{- $dbName := "piwigo" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- $dbRootPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-mariadb-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "MARIADB_PASSWORD") | b64dec) -}}
    {{- $dbRootPass = ((index .data "MARIADB_ROOT_PASSWORD") | b64dec) -}}
  {{- end }}
secret:
  mariadb-creds:
    enabled: true
    data:
      MARIADB_USER: {{ $dbUser }}
      MARIADB_DATABASE: {{ $dbName }}
      MARIADB_PASSWORD: {{ $dbPass }}
      MARIADB_ROOT_PASSWORD: {{ $dbRootPass }}
      MARIADB_HOST: {{ $dbHost }}

  {{- if not (mustRegexMatch "^.+@.+\\..+$" .Values.piwiConfig.adminMail) -}}
    {{- fail (printf "Piwigo - Mail [%s] is not valid." .Values.piwiConfig.adminMail) -}}
  {{- end -}}
  {{- $installArgs := (list
      (printf "language=%s" .Values.piwiConfig.language)
      (printf "dbhost=%s" $dbHost)
      (printf "dbuser=%s" $dbUser)
      (printf "dbpasswd=%s" $dbPass)
      (printf "dbname=%s" $dbName)
      "prefix=piwigo_"
      (printf "admin_name=%s" .Values.piwiConfig.adminName)
      (printf "admin_pass1=%s" .Values.piwiConfig.adminPass)
      (printf "admin_pass2=%s" .Values.piwiConfig.adminPass)
      (printf "admin_mail=%s" .Values.piwiConfig.adminMail)
      "install=Start+installation"
  ) }}
  piwigo-creds:
    enabled: true
    data:
      INSTALL_STRING: {{ join "&" $installArgs }}
{{- end -}}
