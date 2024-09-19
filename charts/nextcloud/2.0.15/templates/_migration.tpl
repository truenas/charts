{{- define "nextcloud.get-versions" -}}
  {{- $oldChartVersion := "" -}}
  {{- $newChartVersion := "" -}}

  {{/* Safely access the context, so it wont block CI */}}
  {{- if hasKey .Values.global "ixChartContext" -}}
    {{- if .Values.global.ixChartContext.upgradeMetadata -}}

      {{- $oldChartVersion = .Values.global.ixChartContext.upgradeMetadata.oldChartVersion -}}
      {{- $newChartVersion = .Values.global.ixChartContext.upgradeMetadata.newChartVersion -}}
      {{- if and (not $oldChartVersion) (not $newChartVersion) -}}
        {{- fail "Upgrade Metadata is missing. Cannot proceed" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- toYaml (dict "old" $oldChartVersion "new" $newChartVersion) -}}
{{- end -}}

{{- define "nextcloud.migration" -}}
  {{- $versions := (fromYaml (include "nextcloud.get-versions" $)) -}}
  {{- if and $versions.old $versions.new -}}
    {{- $oldV := semver $versions.old -}}
    {{- $newV := semver $versions.new -}}

    {{/* If new is v2.x.x */}}
    {{- if eq ($newV.Major | int) 2 -}}
      {{/* And old is v1.x.x, but lower than .6.61 */}}
      {{- if and (eq $oldV.Major 1) (or (ne $oldV.Minor 6) (lt ($oldV.Patch | int) 61)) -}}
        {{/* Block the upgrade */}}
        {{- fail "Migration to 2.x.x is only allowed from 1.6.61 or higher" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "nextcloud.is-migration" -}}
  {{- $isMigration := "" -}}
  {{- $versions := (fromYaml (include "nextcloud.get-versions" $)) -}}
  {{- if $versions.old -}}
    {{- $oldV := semver $versions.old -}}
    {{- if and (eq $oldV.Major 1) (eq ($oldV.Minor | int) 6) (eq ($oldV.Patch | int) 61) -}}
      {{- $isMigration = "true" -}}
    {{- end -}}
  {{- end -}}

  {{- $isMigration -}}
{{- end -}}
