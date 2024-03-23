{{- define "upb.validation" -}}

  {{- $validTypes := (list "motion" "person" "vehicle" "ring") -}}
  {{- range $type := .Values.upbConfig.detectionTypes -}}
    {{- if not (mustHas $type $validTypes) -}}
      {{- fail (printf "Unifi Protect Backup - Expected Detection type to be one of [%s], but got [%s]" (join ", " $validTypes) $type) -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
