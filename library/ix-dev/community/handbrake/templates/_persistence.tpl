{{- define "handbrake.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.handbrakeStorage.config) | nindent 4 }}
    targetSelector:
      handbrake:
        handbrake:
          mountPath: /config
  storage:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.handbrakeStorage.storage) | nindent 4 }}
    targetSelector:
      handbrake:
        handbrake:
          mountPath: /storage
  output:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.handbrakeStorage.output) | nindent 4 }}
    targetSelector:
      handbrake:
        handbrake:
          mountPath: /output
  watch:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.handbrakeStorage.watch) | nindent 4 }}
    targetSelector:
      handbrake:
        handbrake:
          mountPath: /watch
  varrun:
    enabled: true
    type: emptyDir
    targetSelector:
      handbrake:
        handbrake:
          mountPath: /var/run
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      handbrake:
        handbrake:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.handbrakeStorage.additionalStorages }}
  {{ printf "handbrake-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      handbrake:
        handbrake:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
