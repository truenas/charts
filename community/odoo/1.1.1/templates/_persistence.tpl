{{- define "odoo.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.odooStorage.data) | nindent 4 }}
    targetSelector:
      odoo:
        odoo:
          mountPath: /var/lib/odoo
        02-db-init:
          mountPath: /var/lib/odoo
  addons:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.odooStorage.addons) | nindent 4 }}
    targetSelector:
      odoo:
        odoo:
          mountPath: /mnt/extra-addons
        02-db-init:
          mountPath: /mnt/extra-addons
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      odoo:
        odoo:
          mountPath: /tmp
        02-db-init:
          mountPath: /tmp

  config:
    enabled: true
    type: secret
    objectName: odoo-config
    targetSelector:
      odoo:
        odoo:
          mountPath: /etc/odoo/odoo.conf
          readOnly: true
          subPath: odoo.conf
        02-db-init:
          mountPath: /etc/odoo/odoo.conf
          readOnly: true
          subPath: odoo.conf

  {{- range $idx, $storage := .Values.odooStorage.additionalStorages }}
  {{ printf "odoo-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      odoo:
        odoo:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.odooStorage.pgData
            "pgBackup" .Values.odooStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
