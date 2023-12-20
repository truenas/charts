{{- define "twofauth.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.twofauthStorage.config.type }}
    datasetName: {{ .Values.twofauthStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.twofauthStorage.config.hostPath | default "" }}
    targetSelector:
      twofauth:
        twofauth:
          mountPath: /2fauth
        01-permissions:
          mountPath: /mnt/directories/2fauth
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      twofauth:
        twofauth:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.twofauthStorage.additionalStorages }}
  {{ printf "twofauth-%v" (int $idx) }}:
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
      twofauth:
        twofauth:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
