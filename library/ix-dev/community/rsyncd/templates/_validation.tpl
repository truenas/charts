{{- define "rsync.validation" -}}
  {{- $reservedParams := (list
                          "port" "use chroot" "pid file"
                          "max connections"
                          ) -}}

  {{- if .Values.rsyncConfig.logToStdout -}}
    {{- $reservedParams = mustAppend $reservedParams "log file" -}}
  {{- end -}}

  {{- range .Values.rsyncConfig.auxParams -}}
    {{- if mustHas .param $reservedParams -}}
      {{- fail (printf "rsync - Overriding parameter [%v] is not allowed." .param) -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
