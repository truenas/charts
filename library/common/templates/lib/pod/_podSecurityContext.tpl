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

  {{/* Override with pods option */}}
  {{- with $objectData.podSpec.securityContext -}}
    {{- $secContext = mustMergeOverwrite $secContext . -}}
  {{- end -}}

  {{/* TODO: Add supplemental groups
    devices (5, 10, 20, 24) (Only when devices is assigned on the pods containers)
    TODO: Unit Test the above cases
  */}}

  {{- $gpuAdded := false -}}
  {{- range $GPUValues := $rootCtx.Values.scaleGPU -}}
    {{/* If there is a selector and pod is selected */}}
    {{- if $GPUValues.targetSelector -}}
      {{- if mustHas $objectData.shortName ($GPUValues.targetSelector | keys) -}}
        {{- $gpuAdded = true -}}
      {{- end -}}
    {{/* If there isnt a selector, but pod is primary */}}
    {{- else if $objectData.primary -}}
      {{- $gpuAdded = true -}}
    {{- end -}}
  {{- end -}}

  {{- if $gpuAdded -}}
    {{- $_ := set $secContext "supplementalGroups" (concat $secContext.supplementalGroups (list 44 107)) -}}
  {{- end -}}

  {{- $portRange := fromJson (include "ix.v1.common.lib.helpers.securityContext.getPortRange" (dict "rootCtx" $rootCtx "objectData" $objectData)) -}}
  {{- if and $portRange.low (le (int $portRange.low) 1024) -}} {{/* If a container wants to bind a port <= 1024 change the unprivileged_port_start */}}
    {{- if ne (include "ix.v1.common.lib.pod.hostNetwork" (dict "rootCtx" $rootCtx "objectData" $objectData)) "true" -}}
      {{- $_ := set $secContext "sysctls" (mustAppend $secContext.sysctls (dict "name" "net.ipv4.ip_unprivileged_port_start" "value" (printf "%v" $portRange.low))) -}}
    {{- end -}}
  {{- end -}}

  {{- if or (kindIs "invalid" $secContext.fsGroup) (eq (toString $secContext.fsGroup) "") -}}
    {{- fail "Pod - Expected non-empty <fsGroup>" -}}
  {{- end -}}

  {{/* Used by the fixedEnv template */}}
  {{- $_ := set $objectData.podSpec "calculatedFSGroup" $secContext.fsGroup -}}

  {{- if not $secContext.fsGroupChangePolicy -}}
    {{- fail "Pod - Expected non-empty <fsGroupChangePolicy>" -}}
  {{- end -}}

  {{- $policies := (list "Always" "OnRootMismatch") -}}
  {{- if not (mustHas $secContext.fsGroupChangePolicy $policies) -}}
    {{- fail (printf "Pod - Expected <fsGroupChangePolicy> to be one of [%s], but got [%s]" (join ", " $policies) $secContext.fsGroupChangePolicy) -}}
  {{- end }}
fsGroup: {{ include "ix.v1.common.helper.makeIntOrNoop" $secContext.fsGroup }}
fsGroupChangePolicy: {{ $secContext.fsGroupChangePolicy }}
  {{- with $secContext.supplementalGroups }}
supplementalGroups:
    {{- range . }}
  - {{ include "ix.v1.common.helper.makeIntOrNoop" . }}
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
