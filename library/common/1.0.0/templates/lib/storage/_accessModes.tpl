{{/* PVC - Access Modes */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pvc.accessModes" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData: The object data of the pvc
*/}}

{{- define "ix.v1.common.lib.pvc.accessModes" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $accessModes := $objectData.accessModes -}}

  {{- if kindIs "string" $accessModes -}}
    {{- $accessModes = (list $accessModes) -}}
  {{- end -}}

  {{- if not $accessModes -}}
    {{- $accessModes = $rootCtx.Values.fallbackDefaults.pvcAccessModes -}}
  {{- end -}}

  {{- $validAccessModes := (list "ReadWriteOnce" "ReadOnlyMany" "ReadWriteMany" "ReadWriteOncePod") -}}

  {{- range $accessModes -}}
    {{- $mode := tpl . $rootCtx -}}
    {{- if not (mustHas $mode $validAccessModes) -}}
      {{- fail (printf "PVC - Expected <accessModes> entry to be one of [%s], but got [%s]" (join ", " $validAccessModes) $mode) -}}
    {{- end }}
- {{ $mode }}
  {{- end -}}
{{- end -}}
