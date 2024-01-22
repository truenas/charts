{{- define "filebrowser.persistence" -}}
{{- $configBasePath := "/config" }}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.filebrowserStorage.config) | nindent 4 }}
    targetSelector:
      filebrowser:
        filebrowser:
          mountPath: {{ $configBasePath }}
        02-init-config:
          mountPath: {{ $configBasePath }}
        {{- if and (eq .Values.filebrowserStorage.config.type "ixVolume")
                  (not (.Values.filebrowserStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  {{- if not .Values.filebrowserStorage.additionalStorages -}}
    {{- fail "Filebrowser - Expected at least 1 additional storage" -}}
  {{- end -}}
  {{- range $idx, $storage := .Values.filebrowserStorage.additionalStorages }}
    {{- if not (hasPrefix "/" $storage.mountPath) -}}
      {{- fail (printf "Filebrowser - Expected [Mount Path] to start with [/], but got [%v]" $storage.mountPath) -}}
    {{- end }}
  {{ printf "filebrowser-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      filebrowser:
        filebrowser:
          mountPath: /data{{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

{{/* Certificate */}}
{{- with .Values.filebrowserNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: filebrowser-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      filebrowser:
        filebrowser:
          mountPath: {{ $configBasePath }}/certs
          readOnly: true

scaleCertificate:
  filebrowser-cert:
    enabled: true
    id: {{ . }}
{{- end -}}
{{- end -}}
