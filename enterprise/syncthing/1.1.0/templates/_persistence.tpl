{{- define "syncthing.persistence" -}}
persistence:
  home:
    enabled: true
    type: {{ .Values.syncthingStorage.home.type }}
    datasetName: {{ .Values.syncthingStorage.home.datasetName | default "" }}
    hostPath: {{ .Values.syncthingStorage.home.hostPath | default "" }}
    targetSelector:
      syncthing:
        syncthing:
          mountPath: /var/syncthing
        01-certs:
          mountPath: /var/syncthing
  configure:
    enabled: true
    type: configmap
    objectName: syncthing-configure
    defaultMode: "0770"
    targetSelector:
      syncthing:
        syncthing:
          mountPath: /configure.sh
          subPath: configure.sh
  truenas-logo:
    enabled: true
    type: configmap
    objectName: syncthing-truenas-logo
    defaultMode: "0770"
    targetSelector:
      syncthing:
        syncthing:
          mountPath: /var/truenas/assets/gui/default/assets/img/logo-horizontal.svg
          subPath: logo-horizontal.svg

  {{- if not .Values.syncthingStorage.additionalStorages -}}
    {{- fail "Syncthing - Expected at least one additional storage defined" -}}
  {{- end -}}

  {{- range $idx, $storage := .Values.syncthingStorage.additionalStorages }}
  {{ printf "sync-%v" (int $idx) }}:
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
      syncthing:
        syncthing:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- if .Values.syncthingNetwork.certificateID }}
  certs:
    enabled: true
    type: secret
    objectName: syncthing-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: https-key.pem
      - key: tls.crt
        path: https-cert.pem
    targetSelector:
      syncthing:
        01-certs:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  syncthing-cert:
    enabled: true
    id: {{ .Values.syncthingNetwork.certificateID }}
    {{- end -}}
{{- end -}}
