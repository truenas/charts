{{/* Returns PVC Volume */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.volume.pvc" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the volume.
*/}}
{{- define "ix.v1.common.lib.pod.volume.pvc" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $pvcName := (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $rootCtx) $objectData.shortName) -}}
  {{- with $objectData.existingClaim -}}
    {{- $pvcName = tpl . $rootCtx -}}
  {{- end -}}

  {{- if mustHas $objectData.type (list "nfs-pv-pvc" "smb-pv-pvc") -}}
    {{- $size := $objectData.size | default $rootCtx.Values.fallbackDefaults.pvcSize -}}
    {{- $hashValues := (printf "%s-%s-%s" $size $objectData.server $objectData.share) -}}
    {{- if $objectData.domain -}}
      {{- $hashValues = (printf "%s-%s" $hashValues $objectData.domain) -}}
    {{- end -}}
    {{/* Generate the unique claim name */}}
    {{- $hash := adler32sum $hashValues -}}
    {{- $pvcName = (printf "%s-%v" $pvcName $hash) -}}
  {{- end }}
- name: {{ $objectData.shortName }}
  persistentVolumeClaim:
    claimName: {{ $pvcName }}
{{- end -}}
