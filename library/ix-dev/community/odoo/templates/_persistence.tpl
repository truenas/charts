{{- define "odoo.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.odooStorage.data.type }}
    datasetName: {{ .Values.odooStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.odooStorage.data.hostPath | default "" }}
    targetSelector:
      odoo:
        odoo:
          mountPath: /var/lib/odoo
        01-permissions:
          mountPath: /mnt/directories/odoo_data
        03-db-init:
          mountPath: /var/lib/odoo
  addons:
    enabled: true
    type: {{ .Values.odooStorage.addons.type }}
    datasetName: {{ .Values.odooStorage.addons.datasetName | default "" }}
    hostPath: {{ .Values.odooStorage.addons.hostPath | default "" }}
    targetSelector:
      odoo:
        odoo:
          mountPath: /mnt/extra-addons
        01-permissions:
          mountPath: /mnt/directories/odoo_addons
        03-db-init:
          mountPath: /mnt/extra-addons
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      odoo:
        odoo:
          mountPath: /tmp
        03-db-init:
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
        03-db-init:
          mountPath: /etc/odoo/odoo.conf
          readOnly: true
          subPath: odoo.conf

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.odooStorage.pgData
            "pgBackup" .Values.odooStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
