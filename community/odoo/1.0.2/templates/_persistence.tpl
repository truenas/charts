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
  # Postgres
  postgresdata:
    enabled: true
    type: {{ .Values.odooStorage.pgData.type }}
    datasetName: {{ .Values.odooStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.odooStorage.pgData.hostPath | default "" }}
    targetSelector:
      # Postgres pod
      postgres:
        # Postgres container
        postgres:
          mountPath: /var/lib/postgresql/data
        # Permissions container
        permissions:
          mountPath: /mnt/directories/postgres_data
  postgresbackup:
    enabled: true
    type: {{ .Values.odooStorage.pgBackup.type }}
    datasetName: {{ .Values.odooStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.odooStorage.pgBackup.hostPath | default "" }}
    targetSelector:
      # Postgres backup pod
      postgresbackup:
        # Postgres backup container
        postgresbackup:
          mountPath: /postgres_backup
        # Permissions container
        permissions:
          mountPath: /mnt/directories/postgres_backup
{{- end -}}
