{{- define "upb.configuration" -}}
secret:
  upb-creds:
    enabled: true
    data:
      UFP_USERNAME: {{ .Values.upbConfig.unifiProtectUsername | quote }}
      UFP_PASSWORD: {{ .Values.upbConfig.unifiProtectPassword | quote }}
      UFP_ADDRESS: {{ .Values.upbConfig.unifiProtectAddress | quote }}
      UFP_PORT: {{ .Values.upbConfig.unifiProtectPort | quote }}
      UFP_SSL_VERIFY: {{ .Values.upbConfig.unifiProtectVerifySsl | quote }}

configmap:
  upb-config:
    enabled: true
    data:
      SQLITE_PATH: /config/database/events.sqlite
      RCLONE_DESTINATION: {{ .Values.upbConfig.rcloneDestination | quote }}
      SKIP_MISSING: {{ .Values.upbConfig.skipMissing | quote }}
      {{- if .Values.upbConfig.ignoreCameras }}
      IGNORE_CAMERAS: {{ join " " .Values.upbConfig.ignoreCameras | quote }}
      {{- end -}}
      {{- if .Values.upbConfig.detectionTypes }}
      DETECTION_TYPES: {{ join "," .Values.upbConfig.detectionTypes | quote }}
      {{- end -}}
      {{- if .Values.upbConfig.rcloneArgs }}
      RCLONE_ARGS: {{ join " " .Values.upbConfig.rcloneArgs | quote }}
      {{- end -}}
      {{- if .Values.upbConfig.rclonePurgeArgs }}
      RCLONE_PURGE_ARGS: {{ join " " .Values.upbConfig.rcloneArgs | quote }}
      {{- end -}}
{{- end -}}
