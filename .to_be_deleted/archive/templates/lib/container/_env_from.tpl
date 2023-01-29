{{/* Call this template like this:
{{- include "ix.v1.common.container.envFrom" (dict "envFrom" $envFrom "root" $root "containerName" $containerName) -}}
*/}}

{{/* Environment Variables From included by the container */}}
{{- define "ix.v1.common.container.envFrom" -}}
  {{- $envFrom := .envFrom -}}
  {{- $containerName := .containerName -}}
  {{- $root := .root -}}

  {{- $envDict := (dict "envs" $envFrom) -}}
  {{- if $envFrom -}}
    {{- $envFrom = (fromYaml (tpl ($envDict | toYaml) $root)).envs -}}
  {{- end -}}

  {{- range $envFrom -}}
    {{- if and .secretRef .configMapRef -}}
      {{- fail "You can't define both secretRef and configMapRef on the same item." -}}
    {{- end -}}
    {{- if .secretRef }}
      {{- $secretName := required "Name is required for secretRef in envFrom." .secretRef.name }}
- secretRef:
    name: {{ $secretName | quote }}
    {{- include "ix.v1.common.util.storeEnvFromVarsForCheck" (dict "root" $root "containerName" $containerName "source" (printf "%s-%s" "secret" $secretName)) -}}
    {{- else if .configMapRef }}
      {{- $configName := required "Name is required for configMapRef in envFrom." .configMapRef.name }}
- configMapRef:
    name: {{ $configName | quote }}
    {{- include "ix.v1.common.util.storeEnvFromVarsForCheck" (dict "root" $root "containerName" $containerName "source" (printf "%s-%s" "configmap" $configName)) -}}
    {{- else -}}
      {{- fail "Not valid Ref or <name> key is missing in envFrom." -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
