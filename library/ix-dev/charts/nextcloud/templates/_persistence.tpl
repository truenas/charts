{{- define "nextcloud.persistence" -}}
persistence:
  {{/* Due to the previous volume structure, we can't really migrate it
       without moving data between directories. Especially without a way to notify user before.
       So if its an old install, we need to use the previous structure.
  */}}

  {{- if .Values.ncStorage.isPreMigrationInstallation }}
  oldhtml:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ncStorage.old) | nindent 4 }}
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: /var/www/html
          subPath: html
      nextcloud-cron:
        nextcloud-cron:
          mountPath: /var/www/html
          subPath: html
  olddata:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ncStorage.old) | nindent 4 }}
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: {{ .Values.ncConfig.dataDir }}
          subPath: data
      nextcloud-cron:
        nextcloud-cron:
          mountPath: {{ .Values.ncConfig.dataDir }}
          subPath: data
  oldconfig:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ncStorage.old) | nindent 4 }}
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: /var/www/html/config
          subPath: config
      nextcloud-cron:
        nextcloud-cron:
          mountPath: /var/www/html/config
          subPath: config
  oldcustomapps:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ncStorage.old) | nindent 4 }}
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: /var/www/html/custom_apps
          subPath: custom_apps
      nextcloud-cron:
        nextcloud-cron:
          mountPath: /var/www/html/custom_apps
          subPath: custom_apps
  oldthemes:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ncStorage.old) | nindent 4 }}
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: /var/www/html/themes
          subPath: themes
      nextcloud-cron:
        nextcloud-cron:
          mountPath: /var/www/html/themes
          subPath: themes
  {{- else }}
  html:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ncStorage.html) | nindent 4 }}
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: /var/www/html
      nextcloud-cron:
        nextcloud-cron:
          mountPath: /var/www/html
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.ncStorage.data) | nindent 4 }}
    targetSelector:
      nextcloud:
        nextcloud:
          mountPath: {{ .Values.ncConfig.dataDir }}
      nextcloud-cron:
        nextcloud-cron:
          mountPath: {{ .Values.ncConfig.dataDir }}
          {{- end }}
  {{- end }}

  # Configuration files mounting
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
