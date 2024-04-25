{{- define "syncthing.persistence" -}}
persistence:
  home:
    enabled: true
    {{- include "syncthing.storage.ci.migration" (dict "storage" .Values.syncthingStorage.home) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.syncthingStorage.home) | nindent 4 }}
    targetSelector:
      syncthing:
        syncthing:
          mountPath: /var/syncthing
        01-certs:
          mountPath: /var/syncthing
  configure:
    enabled: true
    type: configmap
    objectName: syncthing-configure
    defaultMode: "0770"
    targetSelector:
      syncthing:
        syncthing:
          mountPath: /configure.sh
          subPath: configure.sh
  truenas-logo:
    enabled: true
    type: configmap
    objectName: syncthing-truenas-logo
    defaultMode: "0770"
    targetSelector:
      syncthing:
        syncthing:
          mountPath: /var/truenas/assets/gui/default/assets/img/logo-horizontal.svg
          subPath: logo-horizontal.svg

  {{- if not .Values.syncthingStorage.additionalStorages -}}
    {{- fail "Syncthing - Expected at least one additional storage defined" -}}
  {{- end -}}

  {{- range $idx, $storage := .Values.syncthingStorage.additionalStorages }}
  {{- if eq $storage.type "smb-pv-pvc" -}}
    {{- if $storage.smbConfig.migrationMode -}}
      {{- $_ := set $storage "readOnly" true -}}
      {{- $_ := set $storage.smbConfig "mountOptions" (list
        (dict "key" "noperm")
        (dict "key" "cifsacl")
        (dict "key" "vers" "value" "3.0")
      ) -}}
    {{- end -}}
  {{- end }}
  {{ printf "sync-%v" (int $idx) }}:
    enabled: true
    {{- include "syncthing.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      syncthing:
        syncthing:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- if .Values.syncthingNetwork.certificateID }}
  certs:
    enabled: true
    type: secret
    objectName: syncthing-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: https-key.pem
      - key: tls.crt
        path: https-cert.pem
    targetSelector:
      syncthing:
        01-certs:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  syncthing-cert:
    enabled: true
    id: {{ .Values.syncthingNetwork.certificateID }}
    {{- end -}}
{{- end -}}

{{/* TODO: CI only migration, remove on next version bump*/}}
{{- define "syncthing.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
