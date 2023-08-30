{{/* PVC - Storage Class Name */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.storage.storageClassName" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData: The object data of the pvc
*/}}
{{- define "ix.v1.common.lib.storage.storageClassName" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $caller := .caller -}}

  {{/*
    If type is "ix-zfs-pvc":
      Return the value set .Values.global.ixChartContext.storageClassName
    If storageClass is defined on the objectData:
      If the value is "-" (dash):
        Return ""
      Else:
        Return the original defined storageClass (smb-pv-pvc and nfs-pv-pvc will fall into this case)
    Else if there is a storageClass defined in .Values.fallbackDefaults.storageClass: (Default is "")
      Return this
  */}}

  {{- $className := "" -}}
  {{- if eq "ix-zfs-pvc" $objectData.type -}}
    {{- if not $rootCtx.Values.global.ixChartContext.storageClassName -}}
      {{- fail (printf "%s - Expected non-empty <global.ixChartContext.storageClassName> on [ix-zfs-pvc] type" $caller) -}}
    {{- end -}}
    {{- $className = tpl $rootCtx.Values.global.ixChartContext.storageClassName $rootCtx -}}

  {{- else if $objectData.storageClass -}}
    {{- $className = (tpl $objectData.storageClass $rootCtx) -}}

  {{- else if $rootCtx.Values.fallbackDefaults.storageClass -}} {{/* Probably useful in CI scenarios */}}
    {{- $className = tpl $rootCtx.Values.fallbackDefaults.storageClass $rootCtx -}}
  {{- end -}}

{{/*
Empty value on storageClasName key means no storageClass
While absent storageClasName key means use the default storageClass
Because helm strips "", we need to use "-" to represent empty value
*/}}

  {{- if $className -}}
    {{- if eq "-" $className }}
storageClassName: ""
    {{- else }}
storageClassName: {{ $className }}
    {{- end -}}
  {{- end -}}
{{- end -}}
