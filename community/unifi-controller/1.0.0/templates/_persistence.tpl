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
          mountPath: /unifi
        01-permissions:
          mountPath: /mnt/directories/unifi
        02-certs:
          mountPath: /unifi
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      unifi:
        unifi:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.unifiStorage.additionalStorages }}
  {{ printf "unifi-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      unifi:
        unifi:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end -}}

  {{- if .Values.unifiNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: unifi-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: private.key
      - key: tls.crt
        path: public.crt
    targetSelector:
      unifi:
        02-certs:
          mountPath: /ix/cert
          readOnly: true

scaleCertificate:
  unifi-cert:
    enabled: true
    id: {{ .Values.unifiNetwork.certificateID }}
    {{- end -}}
{{- end -}}
