{{/* Init Containers */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.initContainerSpawner" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.initContainerSpawner" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $initContainers := (dict  "init" list
                                "install" list
                                "upgrade" list) -}}

  {{- $types := (list "init" "install" "upgrade") -}}
  {{- range $containerName, $containerValues := $objectData.podSpec.initContainers -}}

    {{- $enabled := $containerValues.enabled -}}
    {{- if kindIs "string" $enabled -}}
      {{- $enabled = tpl $enabled $rootCtx -}}

      {{/* After tpl it becomes a string, not a bool */}}
      {{-  if eq $enabled "true" -}}
        {{- $enabled = true -}}
      {{- else -}}
        {{- $enabled = false -}}
      {{- end -}}
    {{- end -}}

    {{- if $enabled -}}

      {{- if not ($containerValues.type) -}}
        {{- fail "InitContainer - Expected non-empty <type>" -}}
      {{- end -}}

      {{- $containerType := tpl $containerValues.type $rootCtx -}}
      {{- if not (mustHas $containerType $types) -}}
        {{- fail (printf "InitContainer - Expected <type> to be one of [%s], but got [%s]" (join ", " $types) $containerType) -}}
      {{- end -}}

      {{- $container := (mustDeepCopy $containerValues) -}}
      {{- $name := printf "%s-%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $rootCtx) $containerType $containerName -}}

      {{- $_ := set $container "name" $name -}}
      {{- $_ := set $container "shortName" $containerName -}}
      {{- $_ := set $container "podShortName" $objectData.shortName -}}
      {{- $_ := set $container "podPrimary" $objectData.primary -}}
      {{- $_ := set $container "podType" $objectData.type -}}

      {{/* Remove keys that do not apply on init containers */}}
      {{- $_ := set $container "lifecycle" dict -}}
      {{- $_ := set $container "probes" dict -}}
      {{/* Template expects probes dict defined even if enabled */}}
      {{- $_ := set $container.probes "liveness" (dict "enabled" false) -}}
      {{- $_ := set $container.probes "readiness" (dict "enabled" false) -}}
      {{- $_ := set $container.probes "startup" (dict "enabled" false) -}}

      {{/* Created from the pod.securityContext, used by fixedEnv */}}
      {{- $_ := set $container "calculatedFSGroup" $objectData.podSpec.calculatedFSGroup -}}

      {{/* Append to list of containers based on type */}}
      {{- $tempContainers := (get $initContainers $containerType) -}}
      {{- $_ := set $initContainers $containerType (mustAppend $tempContainers $container) -}}
    {{- end -}}
  {{- end -}}

  {{- if $rootCtx.Release.IsInstall -}}
    {{- range $container := (get $initContainers "install") -}}
      {{- include "ix.v1.common.lib.pod.container" (dict "rootCtx" $rootCtx "objectData" $container) -}}
    {{- end -}}
  {{- end -}}

  {{- if $rootCtx.Release.IsUpgrade -}}
    {{- range $container := (get $initContainers "upgrade") -}}
      {{- include "ix.v1.common.lib.pod.container" (dict "rootCtx" $rootCtx "objectData" $container) -}}
    {{- end -}}
  {{- end -}}

  {{- range $container := (get $initContainers "init") -}}
    {{- include "ix.v1.common.lib.pod.container" (dict "rootCtx" $rootCtx "objectData" $container) -}}
  {{- end -}}

{{- end -}}
