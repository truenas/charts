{{- define "rsync.configuration" -}}
{{- include "rsync.validation" $ }}
configmap:
  config:
    enabled: true
    data:
      rsyncd.conf: |
        port = {{ .Values.rsyncNetwork.rsyncPort }}
        use chroot = yes
        pid file = /tmp/rsyncd.pid

        max connections = {{ .Values.rsyncConfig.maxConnections }}
        log file = /dev/stdout

    {{- range $aux := .Values.rsyncConfig.auxParams }}
        {{ printf "%v = %v" $aux.param $aux.value }}
    {{- end }}

    {{- $mods := list -}}
    {{- range $mod := .Values.rsyncModules }}
      {{- if $mod.enabled -}}
        {{- include "rsync.module.validation" (dict "mod" $mod) }}

        {{ printf "[%v]" $mod.name }}
          path = {{ printf "/data/%v" $mod.name }}
          max connections = {{ $mod.maxConnections }}
          uid = {{ $mod.uid }}
          gid = {{ $mod.gid }}
        {{- if $mod.comment }}
          comment = {{ $mod.comment }}
        {{- end }}

        {{- if eq $mod.accessMode "RO" }}
          write only = false
          read only = true
        {{- else if eq $mod.accessMode "WO" }}
          write only = true
          read only = false
        {{- else if eq $mod.accessMode "RW" }}
          read only = false
          write only = false
        {{- end }}

        {{- if $mod.hostsAllow }}
          hosts allow = {{ join " " $mod.hostsAllow }}
        {{- end }}

        {{- if $mod.hostsDeny }}
          hosts deny = {{ join " " $mod.hostsDeny }}
        {{- end }}
        {{- range $aux := $mod.auxParams }}
          {{- include "rsync.aux.validation" (dict "aux" $aux) }}
          {{ printf "%v = %v" $aux.param $aux.value }}
        {{- end }}
      {{- end }}
      {{- $mods = mustAppend $mods $mod.name }}
    {{- end }}

    {{- if not (deepEqual $mods (uniq $mods)) -}}
      {{- fail "Rsync - Module Names must be unique" -}}
    {{- end -}}
{{- end -}}
