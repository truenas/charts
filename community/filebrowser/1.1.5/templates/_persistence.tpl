{{- define "filebrowser.persistence" -}}
{{- $configBasePath := "/config" }}
persistence:
  config:
    enabled: true
    type: {{ .Values.filebrowserStorage.config.type }}
    datasetName: {{ .Values.filebrowserStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.filebrowserStorage.config.hostPath | default "" }}
    targetSelector:
      filebrowser:
        filebrowser:
          mountPath: {{ $configBasePath }}
        02-init-config:
          mountPath: {{ $configBasePath }}
        01-permissions:
          mountPath: /mnt/directories/config
  {{- if not .Values.filebrowserStorage.additionalStorages -}}
    {{- fail "Filebrowser - Expected at least 1 additional storage" -}}
  {{- end -}}
  {{- range $idx, $storage := .Values.filebrowserStorage.additionalStorages }}
    {{- if not (hasPrefix "/" $storage.mountPath) -}}
      {{- fail (printf "Filebrowser - Expected [Mount Path] to start with [/], but got [%v]" $storage.mountPath) -}}
    {{- end }}
  {{ printf "filebrowser-%v" (int $idx) }}:
    {{- $size := "" -}}
    {{- if $storage.size -}}
      {{- $size = (printf "%vGi" $storage.size) -}}
    {{- end }}
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    server: {{ $storage.server | default "" }}
    share: {{ $storage.share | default "" }}
    domain: {{ $storage.domain | default "" }}
    username: {{ $storage.username | default "" }}
    password: {{ $storage.password | default "" }}
    size: {{ $size }}
    {{- if eq $storage.type "smb-pv-pvc" }}
    mountOptions:
      - key: noperm
    {{- end }}
    targetSelector:
      filebrowser:
        filebrowser:
          mountPath: /data{{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
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
