{{/* Returns Env From */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.container.envFrom" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the container.
*/}}
{{- define "ix.v1.common.lib.container.envFrom" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $refs := (list "configMapRef" "secretRef") -}}
  {{- range $envFrom := $objectData.envFrom -}}
    {{- if and (not $envFrom.secretRef) (not $envFrom.configMapRef) -}}
      {{- fail (printf "Container - Expected <envFrom> entry to have one of [%s]" (join ", " $refs)) -}}
    {{- end -}}

    {{- if and $envFrom.secretRef $envFrom.configMapRef -}}
      {{- fail (printf "Container - Expected <envFrom> entry to have only one of [%s], but got both" (join ", " $refs)) -}}
    {{- end -}}

    {{- range $ref := $refs -}}
      {{- with (get $envFrom $ref) -}}
        {{- if not .name -}}
          {{- fail (printf "Container - Expected non-empty <envFrom.%s.name>" $ref) -}}
        {{- end -}}

        {{- $objectName := tpl .name $rootCtx -}}

        {{- $expandName := true -}}
        {{- if kindIs "bool" .expandObjectName -}}
          {{- $expandName = .expandObjectName -}}
        {{- end -}}

        {{- if $expandName -}}
          {{- if eq $ref "configMapRef" -}}
            {{- $configmap := (get $rootCtx.Values.configmap $objectName) -}}
            {{- if not $configmap -}}
              {{- fail (printf "Container - Expected ConfigMap [%s] defined in <envFrom> to exist" $objectName) -}}
            {{- end -}}
            {{- range $k, $v := $configmap.data -}}
              {{- include "ix.v1.common.helper.container.envDupeCheck" (dict "rootCtx" $rootCtx "objectData" $objectData "source" (printf "ConfigMap - %s" $objectName) "key" $k) -}}
            {{- end -}}

          {{- else if eq $ref "secretRef" -}}
            {{- $secret := (get $rootCtx.Values.secret $objectName) -}}
            {{- if not $secret -}}
              {{- fail (printf "Container - Expected Secret [%s] defined in <envFrom> to exist" $objectName) -}}
            {{- end -}}

            {{- range $k, $v := $secret.data -}}
              {{- include "ix.v1.common.helper.container.envDupeCheck" (dict "rootCtx" $rootCtx "objectData" $objectData "source" (printf "Secret - %s" $objectName) "key" $k) -}}
            {{- end -}}
          {{- end -}}

          {{- $objectName = (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $rootCtx) $objectName) -}}
        {{- end }}
- {{ $ref }}:
    name: {{ $objectName | quote }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
