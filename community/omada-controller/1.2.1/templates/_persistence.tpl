{{- define "omada.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "omada.storage.ci.migration" (dict "storage" .Values.omadaStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.omadaStorage.data) | nindent 4 }}
    targetSelector:
      omada:
        omada:
          mountPath: /opt/tplink/EAPController/data
  logs:
    enabled: true
    {{- include "omada.storage.ci.migration" (dict "storage" .Values.omadaStorage.logs) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.omadaStorage.logs) | nindent 4 }}
    targetSelector:
      omada:
        omada:
          mountPath: /opt/tplink/EAPController/logs
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      omada:
        omada:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.omadaStorage.additionalStorages }}
  {{ printf "omada-%v" (int $idx) }}:
    enabled: true
    {{- include "omada.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      omada:
        omada:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end -}}

  {{- if .Values.omadaNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: omada-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      omada:
        omada:
          mountPath: /cert
          readOnly: true

scaleCertificate:
  omada-cert:
    enabled: true
    id: {{ .Values.omadaNetwork.certificateID }}
    {{- end -}}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "omada.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
