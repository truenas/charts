{{/* Returns Pod Security Context */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.securityContext" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.securityContext" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if not $rootCtx.Values.securityContext.pod -}}
    {{- fail "Pod - Expected non-empty <.Values.securityContext.pod>" -}}
  {{- end -}}

  {{/* Initialize from the "global" option */}}
  {{- $secContext := mustDeepCopy $rootCtx.Values.securityContext.pod -}}

  {{/* Override with pod's option */}}
  {{- with $objectData.podSpec.securityContext -}}
    {{- $secContext = mustMergeOverwrite $secContext . -}}
  {{- end -}}

  {{/* TODO: Add supplemental groups
    devices (5, 10, 20, 24) (Only when devices is assigned on the pod's containers)
    TODO: Unit Test the above cases
  */}}

  {{- $addSupplemental := list -}}
  {{- range $GPUValues := $rootCtx.Values.scaleGPU -}}
    {{/* If there is a selector and pod is selected */}}
    {{- if $GPUValues.targetSelector -}}
      {{- if mustHas $objectData.shortName ($GPUValues.targetSelector | keys) -}}
        {{- $addSupplemental = mustAppend $addSupplemental 44 -}}
      {{- end -}}
    {{/* If there isn't a selector, but pod is primary */}}
    {{- else if $objectData.primary -}}
      {{- $addSupplemental = mustAppend $addSupplemental 44 -}}
    {{- end -}}
  {{- end -}}

  {{- if $addSupplemental -}}
    {{- $_ := set $secContext "supplementalGroups" (concat $secContext.supplementalGroups $addSupplemental) -}}
  {{- end -}}

  {{- $portRange := fromJson (include "ix.v1.common.lib.pod.securityContext.getPortRange" (dict "rootCtx" $rootCtx "objectData" $objectData)) -}}
  {{- if and $portRange.low (le (int $portRange.low) 1024) -}}
    {{- $_ := set $secContext "sysctls" (mustAppend $secContext.sysctls (dict "name" "net.ipv4.ip_unprivileged_port_start" "value" (printf "%v" $portRange.low))) -}}
  {{- end -}}

  {{- if not $secContext.fsGroup -}}
    {{- fail "Pod - Expected non-empty <fsGroup>" -}}
  {{- end -}}

  {{- if not $secContext.fsGroupChangePolicy -}}
    {{- fail "Pod - Expected non-empty <fsGroupChangePolicy>" -}}
  {{- end -}}

  {{- $policies := (list "Always" "OnRootMismatch") -}}
  {{- if not (mustHas $secContext.fsGroupChangePolicy $policies) -}}
    {{- fail (printf "Pod - Expected <fsGroupChangePolicy> to be one of [%s], but got [%s]" (join ", " $policies) $secContext.fsGroupChangePolicy) -}}
  {{- end }}
fsGroup: {{ $secContext.fsGroup }}
fsGroupChangePolicy: {{ $secContext.fsGroupChangePolicy }}
  {{- with $secContext.supplementalGroups }}
supplementalGroups:
    {{- range . }}
  - {{ . }}
    {{- end -}}
  {{- else }}
supplementalGroups: []
  {{- end -}}
  {{- with $secContext.sysctls }}
sysctls:
    {{- range . }}
    {{- if not .name -}}
      {{- fail "Pod - Expected non-empty <name> in <sysctls>" -}}
    {{- end -}}
    {{- if not .value -}}
      {{- fail "Pod - Expected non-empty <value> in <sysctls>" -}}
    {{- end }}
  - name: {{ tpl .name $rootCtx | quote }}
    value: {{ tpl .value $rootCtx | quote }}
    {{- end -}}
  {{- else }}
sysctls: []
  {{- end -}}
{{- end -}}

{{/* Returns Lowest and Highest ports assigned to the any container in the pod */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.securityContext.getPortRange" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.securityContext.getPortRange" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{ $portRange := (dict "high" 0 "low" 0) }}

  {{- range $name, $service := $rootCtx.Values.service -}}
    {{- $selected := false -}}
    {{/* If service is enabled... */}}
    {{- if $service.enabled -}}

      {{/* If there is a selector */}}
      {{- if $service.targetSelector -}}

        {{/* And pod is selected */}}
        {{- if eq $service.targetSelector $objectData.shortName -}}
          {{- $selected = true -}}
        {{- end -}}

      {{- else -}}
        {{/* If no selector is defined but pod is primary */}}
        {{- if $objectData.primary -}}
          {{- $selected = true -}}
        {{- end -}}

      {{- end -}}
    {{- end -}}

    {{- if $selected -}}
      {{- range $name, $portValues := $service.ports -}}
        {{- if $portValues.enabled -}}

          {{- $portToCheck := ($portValues.targetPort | default $portValues.port) -}}
          {{- if kindIs "string" $portToCheck -}}
            {{/* Helm stores ints as floats, so convert string to float before comparing */}}
            {{- $portToCheck = (tpl $portToCheck $rootCtx) | float64 -}}
          {{- end -}}

          {{- if or (not $portRange.low) (lt $portToCheck ($portRange.low | float64)) -}}
            {{- $_ := set $portRange "low" $portToCheck -}}
          {{- end -}}

          {{- if or (not $portRange.high) (gt $portToCheck ($portRange.high | float64)) -}}
            {{- $_ := set $portRange "high" $portToCheck -}}
          {{- end -}}

        {{- end -}}
      {{- end -}}
    {{- end -}}

  {{- end -}}

  {{- $portRange | toJson -}}
{{- end -}}
