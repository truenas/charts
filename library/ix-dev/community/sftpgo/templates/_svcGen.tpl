{{- define "sftpgo.svc.gen" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $type := .type -}}

  {{- $enabledServices := (include "sftpgo.svc.enabled" (dict "rootCtx" $rootCtx "type" $type) | fromJsonArray) -}}

{{- with $enabledServices }}
{{ printf "sftpgo-%s" $type }}:
  enabled: true
  type: NodePort
  targetSelector: sftpgo
  ports:
{{- end -}}
  {{- range $idx, $svc := $enabledServices }}
    {{ printf "%s-%d" $type $idx }}:
      enabled: true
      primary: {{ eq ($idx | int) 0 }}
      port: {{ $svc.port }}
      nodePort: {{ $svc.port }}
      targetSelector: sftpgo
  {{- end -}}
{{- end -}}


{{- define "sftpgo.svc.enabled" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $type := .type -}}

  {{- $services := (get $rootCtx.Values.sftpgoNetwork (printf "%sServices" $type)) -}}
  {{- $enabledServices := list -}}

  {{- range $idx, $svc := $services -}}
    {{- if $svc.enabled -}}
      {{- $enabledServices = append $enabledServices $svc -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledServices | toJson -}}
{{- end -}}

{{- define "sftgo.svc.validation" -}}
  {{- $ports := list -}}
  {{- $ports = append $ports .Values.sftpgoNetwork.webPort -}}

  {{- range $k, $v := .Values.sftpgoNetwork -}}
    {{- if (hasSuffix "Services" $k) -}}
      {{- range $idx, $svc := $v -}}
        {{- if $svc.enabled -}}
          {{- $ports = append $ports $svc.port -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if not (deepEqual ($ports | uniq) $ports) -}}
    {{- fail (printf "SFTPGo - Expected ports to be unique for all services, ports defined [%s]" (join ", " $ports)) -}}
  {{- end -}}

{{- end -}}
