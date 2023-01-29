{{/* Returns http for the probe */}}
{{- define "ix.v1.common.container.probes.httpGet" -}}
  {{- $probe := .probe -}}
  {{- $containerName := .containerName -}}
  {{- $defaults := .defaults -}}

  {{- if not $probe.port -}}
    {{- fail (printf "<port> must be defined for <http>/<https> probe types in probe (%s) in (%s) container." $probe.name $containerName) -}}
  {{- end -}}

  {{- if not $probe.path -}}
    {{- fail (printf "<path> must be defined for <http>/<https> probe types in probe (%s) in (%s) container." $probe.name $containerName) -}}
  {{- end -}}

  {{- if not (hasPrefix "/" $probe.path) -}}
    {{- fail (printf "Probe in container (%s) with path (%s), must start with a forward slash -> / <-" $containerName $probe.path) -}}
  {{- end -}}

httpGet:
  path: {{ $probe.path }}
  scheme: {{ $probe.type | upper }}
  port: {{ $probe.port }}
  {{- with $probe.httpHeaders }}
  httpHeaders:
    {{- range $k, $v := . }}
      {{- if or (kindIs "slice" $v) (kindIs "map" $v) -}}
        {{- fail (printf "Lists or Dicts are not allowed in httpHeaders on probe (%s)" $probe.name) -}}
      {{- end }}
    - name: {{ $k }}
      value: {{ toString $v }}
    {{- end }}
  {{- end }}

  {{- include "ix.v1.common.container.probes.timeouts"  (dict "probeSpec" $probe.spec
                                                              "probeName" $probe.name
                                                              "defaults" $defaults
                                                              "containerName" $containerName) }}
{{- end -}}
