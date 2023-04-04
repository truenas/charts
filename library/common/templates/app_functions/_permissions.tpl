{{/* Returns an init container that fixes permissions */}}
{{/* Call this template:
{{ include "ix.v1.common.app.permissions" (dict "UID" 568 "GID" 568 "type" "init") }}

type (optional): init or install (default: install)
UID: UID to change permissions to
GID: GID to change permissions to
*/}}
{{- define "ix.v1.common.app.permissions" -}}
  {{- $type := .type | default "install" -}}
  {{- $containerName := .containerName | default "permissions" -}}
  {{- $mode := .mode | default "always" -}}
  {{- $UID := .UID -}}
  {{- $GID := .GID -}}

  {{- $modes := (list "always" "check") -}}
  {{- if not (mustHas $mode $modes) -}}
    {{- fail (printf "Permissions Container - [mode] must be one of [%s]" (join ", " $modes)) -}}
  {{- end -}}

  {{- if (kindIs "invalid" $type) -}}
    {{- fail "Permissions Container - [type] cannot be empty" -}}
  {{- end -}}
  {{- if (kindIs "invalid" $containerName) -}}
    {{- fail "Permissions Container - [containerName] cannot be empty" -}}
  {{- end -}}
  {{- if (kindIs "invalid" $GID) -}}
    {{- fail "Permissions Container - [GID] cannot be empty" -}}
  {{- end -}}
  {{- if (kindIs "invalid" $UID) -}}
    {{- fail "Permissions Container - [UID] cannot be empty" -}}
  {{- end }}

{{ $containerName }}:
  enabled: true
  type: {{ $type }}
  imageSelector: bashImage
  resources:
    limits:
      cpu: 1000m
      memory: 512Mi
  securityContext:
    runAsUser: 0
    runAsGroup: 0
    runAsNonRoot: false
    readOnlyRootFilesystem: false
    capabilities:
      add:
        - CHOWN
  command: bash
  args:
    - -c
    - |
      for dir in /mnt/directories/*; do
        if [ ! -d "$dir" ]; then
          echo "[$dir] is not a directory, skipping"
          continue
        fi

        echo "Current Permissions on ["$dir"]:"
        stat -c "%u %g" "$dir"

      {{- if eq $mode "check" }} {{/* If mode is check, check parent dir */}}
        if [ $(stat -c %u "$dir") -eq {{ $UID }} ] && [ $(stat -c %g "$dir") -eq {{ $GID }} ]; then
          echo "Permissions are correct. Skipping..."
          fix_perms="false"
        else
          echo "Permissions are incorrect. Fixing..."
          fix_perms="true"
        fi

      {{- else if eq $mode "always" }} {{/* If mode is always, always fix perms */}}

        fix_perms="true"

      {{- end }}

        if [ "$fix_perms" = "true" ]; then
          echo "Changing ownership to {{ $UID }}:{{ $GID }} on: ["$dir"]"
          chown -R {{ $UID }}:{{ $GID }} "$dir"
          echo "Finished changing ownership"
          echo "Permissions after changing ownership:"
          stat -c "%u %g" "$dir"
        fi
      done
{{- end -}}
