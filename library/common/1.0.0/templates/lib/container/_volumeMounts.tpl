{{/* Returns volumeMount list */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.container.volumeMount" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the container.
*/}}
{{- define "ix.v1.common.lib.container.volumeMount" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $volMounts := list -}}

  {{- range $persistenceName, $persistenceValues := $rootCtx.Values.persistence -}}

    {{/* Initialize from the default values */}}
    {{- $volMount := dict -}}
    {{- $_ := set $volMount "name" $persistenceName -}}
    {{- $_ := set $volMount "mountPath" ($persistenceValues.mountPath | default "") -}}
    {{- $_ := set $volMount "subPath" ($persistenceValues.subPath | default "") -}}
    {{- $_ := set $volMount "readOnly" ($persistenceValues.readOnly | default false) -}}
    {{- $_ := set $volMount "mountPropagation" ($persistenceValues.mountPropagation | default "") -}}

    {{/* If persistence is enabled... */}}
    {{- if $persistenceValues.enabled -}}
      {{/* If targetSelectAll is set, means all pods/containers */}}
      {{- if $persistenceValues.targetSelectAll -}}
        {{- $volMounts = mustAppend $volMounts $volMount -}}

      {{/* Else if selector is defined */}}
      {{- else if $persistenceValues.targetSelector -}}
        {{/* If pod is selected */}}
        {{- if mustHas $objectData.podShortName ($persistenceValues.targetSelector | keys) -}}
          {{- $selectorValues := (get $persistenceValues.targetSelector $objectData.podShortName) -}}
          {{- if not (kindIs "map" $selectorValues) -}}
            {{- fail (printf "Persistence - Expected <targetSelector.%s> to be a [dict], but got [%s]" $objectData.podShortName (kindOf $selectorValues)) -}}
          {{- end -}}

          {{- if not $selectorValues -}}
            {{- fail (printf "Persistence - Expected non-empty <targetSelector.%s>" $objectData.podShortName) -}}
          {{- end -}}

          {{/* If container is selected */}}
          {{- if mustHas $objectData.shortName ($selectorValues | keys) -}}
            {{/* Merge with values that might be set for the specific container */}}
            {{- $volMount = mustMergeOverwrite $volMount (get $selectorValues $objectData.shortName) -}}
            {{- $volMounts = mustAppend $volMounts $volMount -}}
          {{- end -}}
        {{- end -}}

      {{/* Else if not selector, but pod and container is primary */}}
      {{- else if and $objectData.podPrimary $objectData.primary -}}
        {{- $volMounts = mustAppend $volMounts $volMount -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- range $volMount := $volMounts -}}
    {{/* Expand values */}}
    {{- $_ := set $volMount "mountPath" (tpl $volMount.mountPath $rootCtx) -}}
    {{- $_ := set $volMount "subPath" (tpl $volMount.subPath $rootCtx) -}}
    {{- $_ := set $volMount "mountPropagation" (tpl $volMount.mountPropagation $rootCtx) -}}

    {{- if not $volMount.mountPath -}}
      {{- fail "Persistence - Expected non-empty <mountPath>" -}}
    {{- end -}}

    {{- if not (hasPrefix "/" $volMount.mountPath) -}}
      {{- fail "Persistence - Expected <mountPath> to start with a forward slash [/]" -}}
    {{- end -}}

    {{- $propagationTypes := (list "None" "HostToContainer" "Bidirectional") -}}
    {{- if and $volMount.mountPropagation (not (mustHas $volMount.mountPropagation $propagationTypes)) -}}
      {{- fail (printf "Persistence - Expected <mountPropagation> to be one of [%s], but got [%s]" (join ", " $propagationTypes) $volMount.mountPropagation) -}}
    {{- end -}}

    {{- if not (kindIs "bool" $volMount.readOnly) -}}
      {{- fail (printf "Persistence - Expected <readOnly> to be [boolean], but got [%s]" (kindOf $volMount.readOnly)) -}}
    {{- end }}
- name: {{ $volMount.name }}
  mountPath: {{ $volMount.mountPath }}
  readOnly: {{ $volMount.readOnly }}
      {{- with $volMount.subPath }}
  subPath: {{ . }}
      {{- end -}}
      {{- with $volMount.mountPropagation }}
  mountPropagation: {{ . }}
      {{- end -}}
  {{- end -}}

{{- end -}}
