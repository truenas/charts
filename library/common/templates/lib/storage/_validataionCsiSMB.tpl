{{/* Validate SMB CSI */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.storage.smbCSI.validation" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  driver: The name of the driver.
  mountOptions: The mount options.
  server: The server address.
  path: The path to the SMB share.
*/}}
{{- define "ix.v1.common.lib.storage.smbCSI.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if not $objectData.server -}}
    {{- fail "SMB CSI - Expected <server> to be non-empty" -}}
  {{- end -}}

  {{- if not $objectData.path -}}
    {{- fail "SMB CSI - Expected <path> to be non-empty" -}}
  {{- end -}}

  {{- if hasKey $rootCtx.Values.global "ixChartContext" -}}
    {{- if not $rootCtx.Values.global.ixChartContext.hasSMBCSI -}}
      {{- fail "SMB CSI - Not supported CSI" -}}
    {{- end -}}
  {{- end -}}

  {{/* TODO: Allow only specific opts?
  {{- $validOpts := list -}}
  {{- range $opt := $objectData.mountOptions -}}
    {{- $opt = tpl $opt $rootCtx -}}
    {{- if not (mustHas $opt $validOpts) -}}
      {{- fail (printf "SMB CSI - Expected <mountOptions> to be one of [%v], but got [%v]" (join ", " $validOpts) $opt) -}}
    {{- end -}}
  {{- end -}}
  */}}

{{- end -}}
