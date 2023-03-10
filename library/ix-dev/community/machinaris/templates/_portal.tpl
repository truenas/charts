{{- define "machinaris.portal" -}}
---
{{ $allConfig := (include "machinaris.config" $ | fromYaml) }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /webui
  port: {{ $allConfig.machinaris.webPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
