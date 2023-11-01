{{- define "ix.v1.common.helper.isStopped" -}}
  {{- $rootCtx := . -}}

  {{- $stop := "" -}}
  {{- with $rootCtx.Values.global.ixChartContext -}}
    {{- if .isStopped -}}
      {{- $stop = true -}}
    {{- end -}}
  {{- end -}}

  {{- $stop -}}
{{- end -}}
