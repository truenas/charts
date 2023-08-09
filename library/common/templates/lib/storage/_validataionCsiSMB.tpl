{{/* Validate SMB CSI */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.storage.smbCSI.validation" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  driver: The name of the driver.
  mountOptions: The mount options.
  server: The server address.
  share: The share to the SMB share.
*/}}
{{- define "ix.v1.common.lib.storage.smbCSI.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if hasKey $rootCtx.Values.global "ixChartContext" -}}
    {{- if not $rootCtx.Values.global.ixChartContext.hasSMBCSI -}}
      {{- fail "SMB CSI - Not supported CSI" -}}
    {{- end -}}
  {{- end -}}

  {{- $required := (list "server" "share" "username" "password") -}}
  {{- range $item := $required -}}
    {{- if not (get $objectData $item) -}}
      {{- fail (printf "SMB CSI - Expected <%v> to be non-empty" $item) -}}
    {{- end -}}
  {{- end -}}

  {{- if hasPrefix "//" $objectData.server -}}
    {{- fail "SMB CSI - Did not expect <server> to start with [//]" -}}
  {{- end -}}

  {{- if hasPrefix "/" $objectData.share -}}
    {{- fail "SMB CSI - Did not expect <share> to start with [/]" -}}
  {{- end -}}

  {{/* TODO: Allow only specific opts? / set specific opts by default? */}}
  {{- $validOpts := list -}}
  {{- range $opt := $objectData.mountOptions -}}
    {{- if not (kindIs "map" $opt) -}}
      {{- fail (printf "SMB CSI - Expected <mountOption> item to be a dict, but got [%s]" (kindOf $opt)) -}}
    {{- end -}}
    {{- if not $opt.key -}}
      {{- fail "SMB CSI - Expected key in <mountOptions> to be non-empty" -}}
    {{- end -}}

  {{/*
    {{- $key := tpl $opt.key $rootCtx -}}
    {{- if not (mustHas $key $validOpts) -}}
      {{- fail (printf "SMB CSI - Expected <mountOptions> to be one of [%v], but got [%v]" (join ", " $validOpts) $opt) -}}
    {{- end -}}
  */}}
  {{- end -}}
{{- end -}}
