{{- define "unifi.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.unifiStorage.data.type }}
    datasetName: {{ .Values.unifiStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.unifiStorage.data.hostPath | default "" }}
    targetSelector:
      unifi:
        unifi:
          mountPath: /usr/lib/unifi/data
        01-permissions:
          mountPath: /mnt/directories/unifi
        02-migrate:
          mountPath: /usr/lib/unifi/data
  cert:
    # Mounted secrets are combined
    # into a java keystore at startup
    enabled: true
    type: emptyDir
    targetSelector:
      unifi:
        unifi:
          mountPath: /usr/lib/unifi/cert
  logs:
    enabled: true
    type: emptyDir
    targetSelector:
      unifi:
        unifi:
          mountPath: /usr/lib/unifi/logs
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      unifi:
        unifi:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.unifiStorage.additionalStorages }}
  {{ printf "unifi-%v" (int $idx) }}:
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
      unifi:
        unifi:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end -}}

  {{- if .Values.unifiNetwork.certificateID }}
  cert-private:
    enabled: true
    type: secret
    objectName: unifi-cert
    defaultMode: "0600"
    targetSelector:
      unifi:
        unifi:
          mountPath: /usr/lib/unifi/cert/privkey.pem
          subPath: tls.key
          readOnly: true
  cert-public:
    enabled: true
    type: secret
    objectName: unifi-cert
    defaultMode: "0600"
    targetSelector:
      unifi:
        unifi:
          mountPath: /usr/lib/unifi/cert/cert.pem
          subPath: tls.crt
          readOnly: true
scaleCertificate:
  unifi-cert:
    enabled: true
    id: {{ .Values.unifiNetwork.certificateID }}
    {{- end -}}
{{- end -}}
