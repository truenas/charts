{{/* Returns Rules for rbac */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.rbac.rules" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the RBAC.
*/}}
{{/* Parses service accounts, and checks if RBAC have selected any of them */}}
{{- define "ix.v1.common.lib.rbac.rules" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if not $objectData.rules -}}
    {{- fail "RBAC - Expected non-empty <rbac.rules>" -}}
  {{- end -}}

  {{- range $objectData.rules -}}
    {{- if not .apiGroups -}}
      {{- fail "RBAC - Expected non-empty <rbac.rules.apiGroups>" -}}
    {{- end -}}
    {{- if not .resources -}}
      {{- fail "RBAC - Expected non-empty <rbac.rules.resources>" -}}
    {{- end -}}
    {{- if not .verbs -}}
      {{- fail "RBAC - Expected non-empty <rbac.rules.verbs>" -}}
    {{- end -}}

  {{- /* apiGroups */}}
- apiGroups:
    {{- range .apiGroups }}
  - {{ tpl . $rootCtx | quote }}
    {{- end -}}
  {{- /* resources */}}
  resources:
    {{- range .resources -}}
      {{- if not . -}}
        {{- fail "RBAC - Expected non-empty entry in <rbac.rules.resources>" -}}
      {{- end }}
  - {{ tpl . $rootCtx | quote }}
      {{- end -}}
  {{- /* verbs */}}
  verbs:
    {{- range .verbs -}}
      {{- if not . -}}
        {{- fail "RBAC - Expected non-empty entry in <rbac.rules.verbs>" -}}
      {{- end }}
  - {{ tpl . $rootCtx | quote }}
    {{- end -}}
  {{- end -}}

{{- end -}}
