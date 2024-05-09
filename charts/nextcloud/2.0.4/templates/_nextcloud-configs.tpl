{{- define "nextcloud.configs" -}}
{{ $bytesGB := 1073741824 }}
configmap:
  nextcloud-config:
    enabled: true
    data:
      opcache.ini: |
        opcache.memory_consumption={{ .Values.ncConfig.opCacheMemoryConsumption }}

      php.ini: |
        max_execution_time={{ .Values.ncConfig.maxExecutionTime }}

      limitrequestbody.conf: |
        LimitRequestBody {{ mul .Values.ncConfig.maxUploadLimit $bytesGB }}

      occ: |
        #!/bin/bash
        uid="$(id -u)"
        gid="$(id -g)"
        if [ "$uid" = '0' ]; then
          user='www-data'
          group='www-data'
        else
          user="$uid"
          group="$gid"
        fi
        run_as() {
          if [ "$(id -u)" = 0 ]; then
            su -p "$user" -s /bin/bash -c 'php /var/www/html/occ "$@"' - "$@"
          else
            /bin/bash -c 'php /var/www/html/occ "$@"' - "$@"
          fi
        }
        run_as "$@"
{{- end -}}
