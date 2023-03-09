{{/* Returns an init container that fixes permissions */}}
{{/* Call this template:
{{ include "ix.v1.common.app.permissions" (dict "UID" 568 "GID" 568 "type" "init") }}

type (optional): init or install (default: install)
UID: UID to change permissions to
GID: GID to change permissions to
*/}}
{{- define "ix.v1.common.app.permissions" -}}
  {{- $type := .type | default "install" -}}
  {{- $containerName := .containerName | default "permisions" -}}
  {{- $UID := .UID -}}
  {{- $GID := .GID -}}

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
  imageSelector: imageBash
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
      echo "Changing ownership to {{ $UID }}:{{ $GID }} on the following directories:"
      ls -la /mnt/directories
      chown -R {{ $UID }}:{{ $GID }} /mnt/directories
      echo "Finished changing ownership"
      echo "Permissions after changing ownership:"
      ls -la /mnt/directories
{{- end -}}
