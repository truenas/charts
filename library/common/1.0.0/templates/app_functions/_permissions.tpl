{{/* Returns an init container that fixes permissions */}}
{{/* Call this template:
{{ include "ix.v1.common.app.permissions" (dict "UID" 568 "GID" 568 "type" "init") }}

type (optional): init or install (default: install)
UID: UID to change to
GID: GID to change to
*/}}
{{- define "ix.v1.common.app.permissions" -}} {{/* TODO: Maybe move this to common as a named function? */}}
  {{- $type := .type -}}
  {{- $UID := .UID -}}
  {{- $GID := .GID }}
permissions:
  enabled: true
  type: {{ $type | default "install" }}
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
