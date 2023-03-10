{{- define "machinaris.validation" -}}
  {{/* Make sure we have unique coins */}}
  {{- $availableCoins := (include "machinaris.config" $ | fromYaml) | keys -}}
  {{- $availableCoins = mustWithout $availableCoins "machinaris" -}}
  {{- $coinNames := list -}}
  {{- range $coin := .Values.machCoins -}}
    {{- if not $coin.name -}}
      {{- fail "Machinaris - Expected non empty coin name" -}}
    {{- end -}}

    {{- if not (mustHas $coin.name $availableCoins) -}}
      {{- fail (printf "Machinaris - Coin [%s] is not supported. Supported coins are [%s]" $coin.name (join ", " $availableCoins)) -}}
    {{- end -}}
    {{- $coinNames = mustAppend $coinNames $coin.name -}}
  {{- end -}}

  {{- $havePlotDir := false -}}
  {{- range .Values.machStorage.additionalVolumes -}}
    {{- if eq .usedFor "plots" -}}
      {{- $havePlotDir = true -}}
    {{- end -}}
  {{- end -}}
  {{- if not $havePlotDir -}}
    {{- fail "Machinaris - Expected at least 1 storage <Used For> [plots] defined under Machinaris Storage" -}}
  {{- end -}}

  {{- if ne (len $coinNames) (len (uniq $coinNames)) -}}
    {{- fail "Machinaris - Expected each coin to be selected once." -}}
  {{- end -}}

  {{- if not .Values.machNetwork.nodeIP -}}
    {{- fail "Machinaris - Node IP is required" -}}
  {{- end -}}
{{- end -}}
