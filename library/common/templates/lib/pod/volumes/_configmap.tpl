{{/* Returns ConfigMap Volume */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.volume.configmap" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the volume.
*/}}
{{- define "ix.v1.common.lib.pod.volume.configmap" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if not $objectData.objectName -}}
    {{- fail "Persistence - Expected non-empty <objectName> on <configmap> type" -}}
  {{- end -}}

  {{- $objectName := tpl $objectData.objectName $rootCtx -}}
  {{- $expandName := true -}}
  {{- if kindIs "bool" $objectData.expandObjectName -}}
    {{- $expandName = $objectData.expandObjectName -}}
  {{- end -}}

  {{- if $expandName -}}
    {{- $object := (get $rootCtx.Values.configmap $objectName) -}}
    {{- if not $object -}}
      {{- fail (printf "Persistence - Expected configmap [%s] defined in <objectName> to exist" $objectName) -}}
    {{- end -}}
    {{- $objectName = (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $rootCtx) $objectName) -}}
  {{- end -}}

  {{- $defMode := "" -}}

  {{- if (and $objectData.defaultMode (not (kindIs "string" $objectData.defaultMode))) -}}
    {{- fail (printf "Persistence - Expected <defaultMode> to be [string], but got [%s]" (kindOf $objectData.defaultMode)) -}}
  {{- end -}}

  {{- with $objectData.defaultMode -}}
    {{- $defMode = tpl $objectData.defaultMode $rootCtx -}}
  {{- end -}}

  {{- if and $defMode (not (mustRegexMatch "^[0-9]{4}$" $defMode)) -}}
    {{- fail (printf "Persistence - Expected <defaultMode> to have be in format of [\"0777\"], but got [%q]" $defMode) -}}
  {{- end }}
- name: {{ $objectData.shortName }}
  configMap:
    name: {{ $objectName }}
    {{- with $defMode }}
    defaultMode: {{ . }}
    {{- end -}}
    {{- with $objectData.items }}
    items:
      {{- range . -}}
        {{- if not .key -}}
          {{- fail "Persistence - Expected non-empty <items.key>" -}}
        {{- end -}}
        {{- if not .path -}}
          {{- fail "Persistence - Expected non-empty <items.path>" -}}
        {{- end }}
    - key: {{ tpl .key $rootCtx }}
      path: {{ tpl .path $rootCtx }}
        {{- end -}}
    {{- end -}}
{{- end -}}
