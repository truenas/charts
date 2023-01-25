{{/* Call this template like this:
{{- include "ix.v1.common.container.envList" (dict "envList" $envList "root" $root "containerName" $containerName) -}}
*/}}
{{- define "ix.v1.common.container.envList" -}}
  {{- $envList := .envList -}}
  {{- $containerName := .containerName -}}
  {{- $root := .root -}}

  {{/* We need to make sure that is always dict. With nested values.
  Will be removed once the tpl is moved in upper level
  */}}
  {{- $envDict := (dict "envs" $envList) -}}
  {{- if $envList -}}
    {{- $envList = (fromYaml (tpl ($envDict | toYaml) $root)).envs -}}
  {{- end -}}

  {{- $dupeCheck := dict -}}

  {{- with $envList -}}
    {{- range $envList -}}
      {{- if and .name .value -}}
        {{- if mustHas (kindOf .name) (list "map" "slice") -}}
          {{- fail "Name in envList cannot be a map or slice" -}}
        {{- end -}}
        {{- if mustHas (kindOf .value) (list "map" "slice") -}}
          {{- fail "Value in envList cannot be a map or slice" -}}
        {{- end }}
- name: {{ .name }}
  value: {{ .value | quote }}
        {{- $_ := set $dupeCheck .name .value -}}
      {{- else -}}
        {{- fail "Please specify both name and value for environment variable" -}}
      {{- end -}}
    {{- end -}}
    {{- include "ix.v1.common.util.storeEnvsForDupeCheck" (dict "root" $root "source" "envList" "data" $dupeCheck "containers" (list $containerName)) -}}
  {{- end -}}
{{- end -}}
