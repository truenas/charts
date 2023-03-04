{{/* Returns Container Security Context */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.container.securityContext" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the container.
*/}}
{{- define "ix.v1.common.lib.container.securityContext" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{/* Initialize from the "global" options */}}
  {{- $secContext := fromJson (include "ix.v1.common.lib.container.securityContext.calculate" (dict "rootCtx" $rootCtx "objectData" $objectData)) }}
runAsNonRoot: {{ $secContext.runAsNonRoot }}
runAsUser: {{ $secContext.runAsUser }}
runAsGroup: {{ $secContext.runAsGroup }}
readOnlyRootFilesystem: {{ $secContext.readOnlyRootFilesystem }}
allowPrivilegeEscalation: {{ $secContext.allowPrivilegeEscalation }}
privileged: {{ $secContext.privileged }}
seccompProfile:
  type: {{ $secContext.seccompProfile.type }}
  {{- if eq $secContext.seccompProfile.type "Localhost" }}
  localhostProfile: {{ $secContext.seccompProfile.profile }}
  {{- end }}
capabilities:
  {{- if $secContext.capabilities.add }}
  add:
    {{- range $secContext.capabilities.add }}
    - {{ . }}
    {{- end -}}
  {{- else }}
  add: []
  {{- end -}}
  {{- if $secContext.capabilities.drop }}
  drop:
    {{- range $secContext.capabilities.drop }}
    - {{ . }}
    {{- end -}}
  {{- else }}
  drop: []
  {{- end -}}
{{- end -}}

{{/* Calculates Container Security Context */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.container.securityContext.calculate" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the container.
*/}}
{{- define "ix.v1.common.lib.container.securityContext.calculate" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if not $rootCtx.Values.securityContext.container -}}
    {{- fail "Container - Expected non-empty <.Values.securityContext.container>" -}}
  {{- end -}}

  {{/* Initialize from the "global" options */}}
  {{- $secContext := mustDeepCopy $rootCtx.Values.securityContext.container -}}

  {{/* Override with container's options */}}
  {{- with $objectData.securityContext -}}
    {{- $secContext = mustMergeOverwrite $secContext . -}}
  {{- end -}}

  {{/* Validations, as we might endup with null values after merge */}}
  {{- range $key := (list "privileged" "allowPrivilegeEscalation" "runAsNonRoot" "readOnlyRootFilesystem") -}}
    {{- $value := (get $secContext $key) -}}
    {{- if not (kindIs "bool" $value) -}}
      {{- fail (printf "Container - Expected <securityContext.%s> to be [bool], but got [%s] of type [%s]" $key $value (kindOf $value)) -}}
    {{- end -}}
  {{- end -}}

  {{- range $key := (list "runAsUser" "runAsGroup") -}}
    {{- $value := (get $secContext $key) -}}
    {{- if not (mustHas (kindOf $value) (list "float64" "int")) -}}
      {{- fail (printf "Container - Expected <securityContext.%s> to be [int], but got [%s] of type [%s]" $key $value (kindOf $value)) -}}
    {{- end -}}
  {{- end -}}

  {{- if not $secContext.seccompProfile -}}
    {{- fail "Container - Expected <securityContext.seccompProfile> to be defined" -}}
  {{- end -}}

  {{- $profiles := (list "RuntimeDefault" "Localhost" "Unconfined") -}}
  {{- if not (mustHas $secContext.seccompProfile.type $profiles) -}}
    {{- fail (printf "Container - Expected <securityContext.seccompProfile> to be one of [%s], but got [%s]" (join ", " $profiles) $secContext.seccompProfile.type) -}}
  {{- end -}}

  {{- if eq $secContext.seccompProfile.type "Localhost" -}}
    {{- if not $secContext.seccompProfile.profile -}}
      {{- fail "Container - Expected <securityContext.seccompProfile.profile> to be defined on type [Localhost]" -}}
    {{- end -}}
  {{- end -}}

  {{- if not $secContext.capabilities -}}
    {{- fail "Container - Expected <securityContext.capabilities> to be defined" -}}
  {{- end -}}

  {{- range $key := (list "add" "drop") -}}
    {{- $item := (get $secContext.capabilities $key) -}}
    {{- if not (kindIs "slice" $item) -}}
      {{- fail (printf "Container - Expected <securityContext.capabilities.%s> to be [list], but got [%s]" $key (kindOf $item)) -}}
    {{- end -}}

    {{- range $item -}}
      {{- if not (kindIs "string" .) -}}
        {{- fail (printf "Container - Expected items of <securityContext.capabilities.%s> to be [string], but got [%s]" $key (kindOf .)) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if or (eq (int $secContext.runAsUser) 0) (eq (int $secContext.runAsGroup) 0) -}}
    {{- if $secContext.runAsNonRoot -}}
      {{- fail "Container - Expected <securityContext.runAsNonRoot> to be [false] with either [runAsUser, runAsGroup] set to [0]" -}}
    {{- end -}}
  {{- end -}}

  {{- $secContext | toJson -}}
{{- end -}}
