{{/* Validate NFS CSI */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.storage.nfsCSI.validation" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  driver: The name of the driver.
  mountOptions: The mount options.
  server: The server address.
  path: The path to the NFS share.
*/}}
{{- define "ix.v1.common.lib.storage.nfsCSI.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if hasKey $rootCtx.Values.global "ixChartContext" -}}
    {{- if not $rootCtx.Values.global.ixChartContext.hasNFSCSI -}}
      {{- fail "NFS CSI - Not supported CSI" -}}
    {{- end -}}
  {{- end -}}

  {{- $required := (list "server" "path") -}}
  {{- range $item := $required -}}
    {{- if not (get $objectData $item) -}}
      {{- fail (printf "NFS CSI - Expected <%v> to be non-empty" $item) -}}
    {{- end -}}
  {{- end -}}

  {{- if not (hasPrefix "/" $objectData.path) -}}
    {{- fail "NFS CSI - Expected <path> to start with [/]" -}}
  {{- end -}}

  {{/* TODO: Allow only specific opts?
  {{- $validOpts := list -}}
  {{- range $opt := $objectData.mountOptions -}}
    {{- $opt = tpl $opt $rootCtx -}}
    {{- if not (mustHas $opt $validOpts) -}}
      {{- fail (printf "NFS CSI - Expected <mountOptions> to be one of [%v], but got [%v]" (join ", " $validOpts) $opt) -}}
    {{- end -}}
  {{- end -}}
  */}}

{{- end -}}
