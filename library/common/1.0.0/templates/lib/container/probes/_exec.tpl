{{/* Returns exec for the probe */}}
{{- define "ix.v1.common.container.probes.exec" -}}
  {{- $probe := .probe -}}
  {{- $containerName := .containerName -}}
  {{- $defaults := .defaults -}}

  {{- if not $probe.command -}}
    {{- fail (printf "No commands were defined for <exec> type on probe (%s) in (%s) container." $probe.name $containerName) -}}
  {{- end }}

exec:
  command:
  {{- include "ix.v1.common.container.command" (dict "commands" $probe.command) | trim | nindent 4 }}
  {{- include "ix.v1.common.container.probes.timeouts"  (dict "probeSpec" $probe.spec
                                                              "probeName" $probe.name
                                                              "defaults" $defaults
                                                              "containerName" $containerName) }}
{{- end -}}
