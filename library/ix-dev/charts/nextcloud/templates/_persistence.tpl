{{- define "nextcloud.persistence" -}}

persistence:
  html: # TODO:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ncStorage.html) | nindent 4 }}
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: /var/www/html
          {{- if eq (include "isOldIxVol" (dict "storage" .Values.ncStorage.html)) "true" }}
          # If the dataset is coming from on old install, we need to use the `html` subPath of the host
          subPath: html
          {{- end }}
      nextcloud-cron:
        nextcloud-cron:
          mountPath: /var/www/html
          {{- if eq (include "isOldIxVol" (dict "storage" .Values.ncStorage.html)) "true" }}
          # If the dataset is coming from on old install, we need to use the `html` subPath of the host
          subPath: html
          {{- end }}
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ncStorage.data) | nindent 4 }}
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: {{ .Values.ncConfig.dataDir }}
          {{- if eq (include "isOldIxVol" (dict "storage" .Values.ncStorage.data)) "true" }}
          # If the dataset is coming from on old install, we need to use the `data` subPath of the host
          subPath: data
          {{- end }}
      nextcloud-cron:
        nextcloud-cron:
          mountPath: {{ .Values.ncConfig.dataDir }}
          {{- if eq (include "isOldIxVol" (dict "storage" .Values.ncStorage.data)) "true" }}
          # If the dataset is coming from on old install, we need to use the `data` subPath of the host
          subPath: data
          {{- end }}
  nc-config-opcache:
    enabled: true
    type: configmap
    objectName: nextcloud-config
    defaultMode: "0755"
    targetSelector:
      nextcloud:
        nextcloud:
          # z-99 is used to ensure that this file is loaded last
          mountPath: /usr/local/etc/php/conf.d/opcache-z-99.ini
          subPath: opcache.ini
  nc-config-php:
    enabled: true
    type: configmap
    objectName: nextcloud-config
    defaultMode: "0755"
    targetSelector:
      nextcloud:
        nextcloud:
          # z-99 is used to ensure that this file is loaded last
          mountPath: /usr/local/etc/php/conf.d/nextcloud-z-99.ini
          subPath: php.ini
  nc-config-limreqbody:
    enabled: true
    type: configmap
    objectName: nextcloud-config
    defaultMode: "0755"
    targetSelector:
      nextcloud:
        nextcloud:
          # https://github.com/nextcloud/docker/issues/1796
          mountPath: /etc/apache2/conf-enabled/limitrequestbody.conf
          subPath: limitrequestbody.conf
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
      nextcloud-cron:
        nextcloud-cron:
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
  nginx-conf:
    enabled: true
    type: configmap
    objectName: nginx
    defaultMode: "0600"
    items:
      - key: nginx.conf
        path: nginx.conf
    targetSelector:
      nginx:
        nginx:
          mountPath: /etc/nginx
          readOnly: true
  {{- end -}}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.ncStorage.pgData
            "pgBackup" .Values.ncStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}

{{- define "isOldIxVol" -}}
  {{- $oldDatasetName := "ix-nextcloud_data" -}}
  {{- $isOld := "false" -}}
  {{- $storage := .storage -}}

  {{- if eq $storage.type "ixVolume" -}}
    {{- if eq $storage.ixVolumeConfig.datasetName $oldDatasetName -}}
      {{- $isOld = "true" -}}
    {{- end -}}
  {{- end -}}

  {{- $isOld }}
{{- end -}}
