{{- define "wgeasy.migration.checks" -}}
  {{/* Safely access the context, so it wont block CI */}}
  {{- if hasKey .Values.global "ixChartContext" -}}
    {{- if .Values.global.ixChartContext.upgradeMetadata -}}

      {{- $oldChartVersion := .Values.global.ixChartContext.upgradeMetadata.oldChartVersion -}}
      {{- $newChartVersion := .Values.global.ixChartContext.upgradeMetadata.newChartVersion -}}
      {{- if and (not $oldChartVersion) (not $newChartVersion) -}}
        {{- fail "Upgrade Metadata is missing. Cannot proceed" -}}
      {{- end -}}

      {{/* Explode versions */}}
      {{- $oldV := semver $oldChartVersion -}}
      {{- $newV := semver $newChartVersion -}}

      {{/* If new is v2.x.x */}}
      {{- if eq ($newV.Major | int) 2 -}}
        {{/* And old is v1.x.x, but lower than .11 */}}
        {{- if and (eq $oldV.Major 1) (lt ($oldV.Patch | int) 11) -}}
          {{/* Block the upgrade */}}
          {{- fail "Migration to 2.x.x is only allowed from 1.0.11 or higher" -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
