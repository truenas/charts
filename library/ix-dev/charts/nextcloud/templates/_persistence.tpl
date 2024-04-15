{{- define "nextcloud.persistence" -}}
persistence:
  data: # TODO:
    enabled: true
    type: emptyDir
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: {{ .Values.ncConfig.dataDir }}

  # config:
  #   enabled: true
  #   targetSelector:
  #     nextcloud:
  #       nextcloud:
  #         mountPath: /config
  #       01-init-config:
  #         mountPath: /config
  # media:
  #   enabled: true
  #   targetSelector:
  #     nextcloud:
  #       nextcloud:
  #         mountPath: /media
  # default-config:
  #   enabled: true
  #   type: secret
  #   objectName: ha-config
  #   defaultMode: "0744"
  #   items:
  #     - key: configuration.default
  #       path: configuration.default
  #     - key: recorder.default
  #       path: recorder.default
  #     - key: script.sh
  #       path: script.sh
  #   targetSelector:
  #     nextcloud:
  #       01-init-config:
  #         mountPath: /default/init
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.ncStorage.additionalStorages }}
  {{ printf "nc-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
  {{- if .Values.ncNetwork.certificateID }}
  nginx-cert:
    enabled: true
    type: secret
    objectName: nextcloud-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: private.key
      - key: tls.crt
        path: public.crt
    targetSelector:
      nginx:
        nginx:
          mountPath: /etc/nginx-certs
          readOnly: true
  {{- end -}}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.ncStorage.pgData
            "pgBackup" .Values.ncStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
