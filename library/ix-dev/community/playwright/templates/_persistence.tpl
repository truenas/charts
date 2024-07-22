{{- define "playwright.persistence" -}}
persistence:
  project:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.playwrightStorage.project) | nindent 4 }}
    targetSelector:
      playwright:
        playwright:
          mountPath: /project
        {{- if and (eq .Values.playwrightStorage.project.type "ixVolume")
                  (not (.Values.playwrightStorage.project.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/project
        {{- end }}
  {{- range $idx, $storage := .Values.playwrightStorage.additionalStorages }}
  {{ printf "playwright-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      playwright:
        playwright:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
