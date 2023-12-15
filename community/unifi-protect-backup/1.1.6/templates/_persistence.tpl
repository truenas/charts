{{- define "upb.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.upbStorage.config.type }}
    datasetName: {{ .Values.upbStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.upbStorage.config.hostPath | default "" }}
    targetSelector:
      unifi-protect:
        unifi-protect:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  data:
    enabled: true
    type: {{ .Values.upbStorage.data.type }}
    datasetName: {{ .Values.upbStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.upbStorage.data.hostPath | default "" }}
    targetSelector:
      unifi-protect:
        unifi-protect:
          mountPath: /data
        01-permissions:
          mountPath: /mnt/directories/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      unifi-protect:
        unifi-protect:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.upbStorage.additionalStorages }}
  {{ printf "upb-%v" (int $idx) }}:
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
      unifi-protect:
        unifi-protect:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
