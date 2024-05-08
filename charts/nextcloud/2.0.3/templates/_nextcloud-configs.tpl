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
{{- end -}}
