{{- define "syncthing.certContainer" -}}
01-certs:
  enabled: true
  type: init
  imageSelector: image
  securityContext:
    runAsUser: 0
    runAsGroup: 0
    runAsNonRoot: false
    readOnlyRootFilesystem: false
    allowPrivilegeEscalation: true
    capabilities:
      add:
        - FOWNER
        - DAC_OVERRIDE
        - CHOWN
        - SETUID
        - SETGID
        - SETFCAP
        - SETPCAP
  fixedEnv:
    PUID: {{ .Values.syncthingID.user }}
  command:
    - /bin/sh
    - -c
    - |
      #!/bin/sh
      set -e
      configDir=/var/syncthing/config
      # Copy certificates, so that syncthing can use them
      # If we mount the certificates directly, syncthing will not start, as it tries
      # to chmod the whole directory and fails, because the secret is read-only
      if [ ! -d "$configDir" ]; then
        mkdir -p "$configDir"
        chown -R "$PUID:$PGID" "$configDir"
      fi
      cp /certs/https-key.pem "$configDir/https-key.pem"
      cp /certs/https-cert.pem "$configDir/https-cert.pem"
      chown "$PUID:$PGID" "$configDir/https-key.pem"
      chown "$PUID:$PGID" "$configDir/https-cert.pem"
{{- end -}}
