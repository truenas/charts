{{- define "sftgo.validation" -}}
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

  {{- if gt (len $ports) 20 -}} {{/* Arbitrary limit, to avoid overallocating ports */}}
    {{- fail (printf "SFTPGo - Too many ports defined, max 20 ports can be defined [%s]" (join ", " $ports)) -}}
  {{- end -}}

  {{- if not (deepEqual ($ports | uniq) $ports) -}}
    {{- fail (printf "SFTPGo - Expected ports to be unique for all services, ports defined [%s]" (join ", " $ports)) -}}
  {{- end -}}

  {{- if .Values.sftpgoNetwork.ftpdServices -}}
    {{- with .Values.sftpgoNetwork.ftpdPassivePortRange -}}
      {{- if ge (int .start) (int .end) -}}
        {{- fail (printf "SFTPGo - ftpd passive port range start [%d] must be less than end [%d]" (int .start) (int .end)) -}}
      {{- end -}}

      {{- if ge (sub (int .end) (int .start)) 20 -}} {{/* Arbitrary limit, to avoid overallocating ports */}}
        {{- fail (printf "SFTPGo - ftpd passive port range must be less than 20 ports, start [%d] end [%d]" (int .start) (int .end)) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
