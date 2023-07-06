{{- define "syncthing.configure" -}}
{{/*
  https://docs.syncthing.net/users/config.html
  Note: Configuration in the above link does not match the subcommands of the cli
  To get the correct subcommands, run `syncthing cli config <category>`
  It will print all the available subcommands for that category
  "Knobs" are exposed under Values.syncthingConfig, We can exposed those to questions.yaml if we want
 */}}
configmap:
  syncthing-configure:
    enabled: true
    data:
      configure.sh: |
        #!/bin/sh
        set -e
        configDir=/var/syncthing/config

        # Make sure the file exists
        until [ -f "$configDir/config.xml" ]; do
          sleep 2
        done

        # Check the API is running
        until curl --silent --output /dev/null http://localhost:{{ .Values.syncthingNetwork.webPort }}/rest/noauth/health; do
          sleep 2
        done

        function setConfig() {
          syncthing cli --home "$configDir" config $@
        }

        # Now we can use the syncthing cli (wrapper around the API) to set the defaults.
        # Keep in mind that all the below values are not enforced, user can change them
        # while the app is running, but will be re-applied on restart.

        # Category "options" is more like "general" or "global" settings.
        setConfig options announce-lanaddresses set -- {{ ternary "1" "0" .Values.syncthingConfig.announceLANAddresses | quote }}
        setConfig options global-ann-enabled set -- {{ ternary "1" "0" .Values.syncthingConfig.globalDiscovery | quote }}
        setConfig options local-ann-enabled set -- {{ ternary "1" "0" .Values.syncthingConfig.localDiscovery | quote }}
        setConfig options natenabled set -- {{ ternary "1" "0" .Values.syncthingConfig.natTraversal | quote }}
        setConfig options relays-enabled set -- {{ ternary "1" "0" .Values.syncthingConfig.relaying | quote }}
        setConfig options uraccepted set -- {{ ternary "1" "-1" .Values.syncthingConfig.telemetry | quote }}
        setConfig options auto-upgrade-intervalh set -- "0"

        # Category "defaults/folder" contains the default settings for new folders.
        setConfig defaults folder xattr-filter max-total-size set -- 10485760
        setConfig defaults folder xattr-filter max-single-entry-size set -- 2097152
        setConfig defaults folder send-ownership set -- 1
        setConfig defaults folder sync-ownership set -- 1
        setConfig defaults folder send-xattrs set -- 1
        setConfig defaults folder sync-xattrs set -- 1

{{- end -}}
