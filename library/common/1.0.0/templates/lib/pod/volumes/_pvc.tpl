{{/* Returns PVC Volume */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.volume.pvc" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the template. It is used to access the global context.
objectData: The object data to be used to render the volume.
*/}}
{{- define "ix.v1.common.lib.pod.volume.pvc" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $pvcName := (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $rootCtx) $objectData.shortName) -}}
  {{- with $objectData.existingClaim -}}
    {{- $pvcName = tpl . $rootCtx -}}
  {{- end }}
- name: {{ $objectData.shortName }}
  persistentVolumeClaim:
    claimName: {{ $pvcName }}
{{- end -}}
