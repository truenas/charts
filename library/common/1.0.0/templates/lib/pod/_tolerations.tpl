{{/* Returns Tolerations */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.tolerations" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the template. It is used to access the global context.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.tolerations" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $tolerations := list -}}

  {{/* Initialize from the "global" option */}}
  {{- with $rootCtx.Values.podOptions.tolerations -}}
    {{- $tolerations = . -}}
  {{- end -}}

  {{/* Override from the "pod" option */}}
  {{- with $objectData.podSpec.tolerations -}}
    {{- $tolerations = . -}}
  {{- end -}}

  {{- range $tolerations -}}
    {{/* Expand values */}}
    {{- $operator := (tpl (.operator | default "") $rootCtx) -}}
    {{- $key := (tpl (.key | default "") $rootCtx) -}}
    {{- $value := (tpl (.value | default "") $rootCtx) -}}
    {{- $effect := (tpl (.effect | default "") $rootCtx) -}}
    {{- $tolSeconds := .tolerationSeconds -}}

    {{- if not (mustHas $operator (list "Exists" "Equal")) -}}
      {{- fail (printf "Expected <tolerations.operator> to be one of [Exists, Equal] but got [%s]" $operator) -}}
    {{- end -}}

    {{- if and (eq $operator "Equal") (or (not $key) (not $value)) -}}
      {{- fail "Expected non-empty <tolerations.key> and <tolerations.value> with <tolerations.operator> set to [Equal]" -}}
    {{- end -}}

    {{- if and (eq $operator "Exists") $value -}}
      {{- fail (printf "Expected empty <tolerations.value> with <tolerations.operator> set to [Exists], but got [%s]" $value) -}}
    {{- end -}}

    {{- if and $effect (not (mustHas $effect (list "NoExecute" "NoSchedule" "PreferNoSchedule"))) -}}
      {{- fail (printf "Expected <tolerations.effect> to be one of [NoExecute, NoSchedule, PreferNoSchedule], but got [%s]" $effect) -}}
    {{- end -}}

    {{- if and (not (kindIs "invalid" $tolSeconds)) (not (mustHas (kindOf $tolSeconds) (list "int" "float64"))) -}}
      {{- fail (printf "Expected <tolerations.tolerationSeconds> to be a number, but got [%s]" $tolSeconds) -}}
    {{- end }}
- operator: {{ $operator }}
    {{- with $key }}
  key: {{ $key }}
    {{- end -}}
    {{- with $effect }}
  effect: {{ $effect }}
    {{- end -}}
    {{- with $value }}
  value: {{ . }}
    {{- end -}}
    {{- if (mustHas (kindOf $tolSeconds) (list "int" "float64")) }}
  tolerationSeconds: {{ $tolSeconds }}
    {{- end -}}

  {{- end -}}
{{- end -}}
