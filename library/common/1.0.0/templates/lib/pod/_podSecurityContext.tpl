{{/* Returns Pod Security Context */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.securityContext" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the template. It is used to access the global context.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.securityContext" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $secContext := dict -}}

  {{/* Initialize from the "global" option */}}
  {{- with $rootCtx.Values.securityContext.pod  -}}
    {{- $secContext = (mustDeepCopy .) -}}
  {{- end -}}

  {{/* Override with pod's option */}}
  {{- with $objectData.podSpec.securityContext -}}
    {{- $secContext = mustMergeOverwrite $secContext . -}}
  {{- end -}}

  {{/* TODO: Add supplemental groups
    scaleGPU (44) (Only when GPU is enabled on the pod's containers)
    devices (5, 10, 20, 24) (Only when devices is assigned on the pod's containers) */}}
  {{/* TODO: Add sysctls
    net.ipv4.ip_unprivileged_port_start: (Set to the lowest port on the pod's containers)
    net.ipv4.ping_group_range: (Set to the lowest port and highest port on the pod's containers)
  */}}

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
    {{- range $name, $value := . }}
    {{- if not $name -}}
      {{- fail "Pod - Expected non-empty <name> in <sysctls>" -}}
    {{- end -}}
    {{- if not $value -}}
      {{- fail "Pod - Expected non-empty <value> in <sysctls>" -}}
    {{- end }}
  - name: {{ $name }}
    value: {{ $value }}
    {{- end -}}
  {{- else }}
sysctls: []
  {{- end -}}
{{- end -}}
