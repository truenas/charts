{{- define "home-assistant.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.haStorage.config) | nindent 4 }}
    targetSelector:
      home-assistant:
        home-assistant:
          mountPath: /config
        01-init-config:
          mountPath: /config
  media:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.haStorage.media) | nindent 4 }}
    targetSelector:
      home-assistant:
        home-assistant:
          mountPath: /media
  default-config:
    enabled: true
    type: secret
    objectName: ha-config
    defaultMode: "0744"
    items:
      - key: configuration.default
        path: configuration.default
      - key: recorder.default
        path: recorder.default
      - key: script.sh
        path: script.sh
    targetSelector:
      home-assistant:
        01-init-config:
          mountPath: /default/init
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      home-assistant:
        home-assistant:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.haStorage.additionalStorages }}
  {{ printf "ha-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      home-assistant:
        home-assistant:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.haStorage.pgData
            "pgBackup" .Values.haStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
