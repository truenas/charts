{{- define "qbittorrent.configuration" -}}

{{/* Configmaps */}}
configmap:
  qbit-config:
    enabled: true
    data:
      QBITTORRENT__BT_PORT: {{ .Values.qbitNetwork.btPort | quote }}
      QBITTORRENT__PORT: {{ .Values.qbitNetwork.webPort | quote }}

{{- end -}}
