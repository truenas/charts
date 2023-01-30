{{/* Controllers Basic Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.controllers.primaryValidation" $ -}}
*/}}
{{- define "ix.v1.common.lib.controllers.primaryValidation" -}}

  {{/* Initialize values */}}
  {{- $hasPrimary := false -}}
  {{- $hasEnabled := false -}}

  {{/* Go over controllers */}}
  {{- range $name, $controller := .Values.controllers -}}

    {{- if not (mustHas $controller.type (list "Deployment" "StatefulSet" "DaemonSet" "Job" "CronJob")) -}}
      {{- fail (printf "Controller - Expected <type> to be one of [Deployment, StatefulSet, DaemonSet, Job, CronJob], but got [%s]" $controller.type) -}}
    {{- end -}}

    {{/* If controller is enabled */}}
    {{- if $controller.enabled -}}
      {{- $hasEnabled = true -}}

      {{/* And controller is primary */}}
      {{- if and (hasKey $controller "primary") ($controller.primary) -}}

        {{/* Fail if there is already a primary controller */}}
        {{- if $hasPrimary -}}
          {{- fail "Controller - Only one controller can be primary" -}}
        {{- end -}}

        {{- $hasPrimary = true -}}

      {{- end -}}
    {{- end -}}

  {{- end -}}

  {{/* Require at least one primary controller, if any enabled */}}
  {{- if and $hasEnabled (not $hasPrimary) -}}
    {{- fail "Controller - At least one enabled controller must be primary" -}}
  {{- end -}}

{{- end -}}

{{/* Basic Controller Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.controller.basicValidation" (dict "objectData" $objectData) -}}
rootCtx: The root context of the template. It is used to access the global context.
objectData:
  labels: The labels of the object.
  annotations: The annotations of the object.
*/}}
{{- define "ix.v1.common.lib.controller.basicValidation" -}}
  {{- $objectData := .objectData -}}

  {{- if and $objectData.labels (not (kindIs "map" $objectData.labels)) -}}
    {{- fail (printf "Controller - Expected <labels> to be a dictionary, but got [%v]" (kindOf $objectData.labels)) -}}
  {{- end -}}

  {{- if and $objectData.annotations (not (kindIs "map" $objectData.annotations)) -}}
    {{- fail (printf "Controller - Expected <annotations> to be a dictionary, but got [%v]" (kindOf $objectData.annotations)) -}}
  {{- end -}}

{{- end -}}

{{/* Deployment Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.controller.basicValidation" (dict "objectData" $objectData) -}}
rootCtx: The root context of the template. It is used to access the global context.
objectData:
  labels: The labels of the object.
  annotations: The annotations of the object.
*/}}
{{- define "ix.v1.common.lib.controller.deploymentValidation" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{- if $objectData.strategy -}}
    {{- $strategy := $objectData.strategy -}}

    {{- if not (mustHas $strategy (list "Recreate" "RollingUpdate")) -}}
      {{- fail (printf "Deployment - Expected <strategy> to be one of [Recreate, RollingUpdate], but got [%v]" $strategy) -}}
    {{- end -}}

  {{- end -}}

  {{- if $objectData.rollingUpdate -}}
    {{- $rollUp := $objectData.rollingUpdate -}}

    {{- if and $rollUp (not (kindIs "map" $rollUp)) -}}
      {{- fail (printf "Deployment - Expected <rollingUpdate> to be a dictionary, but got [%v]" (kindOf $rollUp)) -}}
    {{- end -}}

  {{- end -}}
{{- end -}}
