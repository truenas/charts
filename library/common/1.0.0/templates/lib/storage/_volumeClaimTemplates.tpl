{{/* Returns Volume Claim Templates */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.workload.volumeClaimTemplates" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.workload.volumeClaimTemplates" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- range $name, $vctValues := $rootCtx.Values.volumeClaimTemplates -}}

    {{- if $vctValues.enabled -}}
      {{- $vct := (mustDeepCopy $vctValues) -}}

      {{- $selected := false -}}
      {{- $_ := set $vct "shortName" $name -}}

      {{- include "ix.v1.common.lib.vct.validation" (dict "objectData" $vct) -}}
      {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $vct.shortName) -}}
      {{- include "ix.v1.common.lib.metadata.validation" (dict "objectData" $vct "caller" "Volume Claim Templates") -}}

      {{/* If targetSelector is set, check if pod is selected */}}
      {{- if $vct.targetSelector -}}
        {{- if (mustHas $objectData.shortName (keys $vct.targetSelector)) -}}
          {{- $selected = true -}}
        {{- end -}}

      {{/* If no targetSelector is set or targetSelectAll, check if pod is primary */}}
      {{- else -}}
        {{- if $objectData.primary -}}
          {{- $selected = true -}}
        {{- end -}}
      {{- end -}}

      {{/* If pod selected */}}
      {{- if $selected -}}
        {{- $vctSize := $rootCtx.Values.fallbackDefaults.vctSize -}}
        {{- with $vct.size -}}
          {{- $vctSize = tpl . $rootCtx -}}
        {{- end }}
- metadata:
    name: {{ $vct.shortName }}
    {{- $labels := (mustMerge ($vct.labels | default dict) (include "ix.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
    {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
    labels:
      {{- . | nindent 6 }}
    {{- end -}}
    {{- $annotations := (mustMerge ($vct.annotations | default dict) (include "ix.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
    {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
    annotations:
      {{- . | nindent 6 }}
    {{- end }}
  spec:
    {{- with (include "ix.v1.common.lib.pvc.storageClassName" (dict "rootCtx" $rootCtx "objectData" $vct "caller" "Volume Claim Templates") | trim) }}
    storageClassName: {{ . }}
    {{- end }}
    accessModes:
      {{- include "ix.v1.common.lib.pvc.accessModes" (dict "rootCtx" $rootCtx "objectData" $vct "caller" "Volume Claim Templates") | trim | nindent 6 }}
    resources:
      requests:
        storage: {{ $vctSize }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
