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
  {{- if and $enabledServices (eq $type "ftpd") -}}
    {{- $start := int $rootCtx.Values.sftpgoNetwork.ftpdPassivePortRange.start -}}
    {{- $end := int $rootCtx.Values.sftpgoNetwork.ftpdPassivePortRange.end -}}
    {{- $end = int (add1 $end) -}}

    {{- range $idx := untilStep $start $end 1 }}
    {{ printf "ftpd-pasv-%d" $idx }}:
      enabled: true
      port: {{ $idx }}
      nodePort: {{ $idx }}
      targetSelector: sftpgo
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "sftpgo.svc.enabled" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $type := .type -}}

  {{- $services := (get $rootCtx.Values.sftpgoNetwork (printf "%sServices" $type)) -}}

  {{- $enabledServices := list -}}
  {{- if $services -}}
    {{- range $idx, $svc := $services -}}
      {{- if $svc.enabled -}}
        {{- $enabledServices = append $enabledServices $svc -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledServices | toJson -}}
{{- end -}}
