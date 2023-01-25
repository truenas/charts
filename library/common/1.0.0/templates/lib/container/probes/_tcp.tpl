{{/* Returns tcp for the probe */}}
{{- define "ix.v1.common.container.probes.tcp" -}}
  {{- $probe := .probe -}}
  {{- $containerName := .containerName -}}
  {{- $defaults := .defaults -}}

  {{- if not $probe.port -}}
    {{- fail (printf "<port> must be defined for <tcp> probe types in probe (%s) in (%s) container." $probe.name $containerName) -}}
  {{- end }}

tcpSocket:
  port: {{ $probe.port }}

  {{- include "ix.v1.common.container.probes.timeouts"  (dict "probeSpec" $probe.spec
                                                              "probeName" $probe.name
                                                              "defaults" $defaults
                                                              "containerName" $containerName) }}
{{- end -}}
