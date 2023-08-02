{{/* PVC Spawwner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.pvc" $ -}}
*/}}

{{- define "ix.v1.common.spawner.pvc" -}}

  {{- range $name, $persistence := .Values.persistence -}}

    {{- if $persistence.enabled -}}

      {{/* Create a copy of the persistence */}}
      {{- $objectData := (mustDeepCopy $persistence) -}}

      {{- $_ := set $objectData "type" ($objectData.type | default $.Values.fallbackDefaults.persistenceType) -}}

      {{/* Perform general validations */}}
      {{- include "ix.v1.common.lib.persistence.validation" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- include "ix.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "Persistence") -}}

      {{/*
        Naming scheme on pvc types:
        pvc creates a PVC with the default StorageClass (Useful for CI or testing on local cluster)
        ix-zfs-pvc creates a PVC and is dependent on iX values injection (eg StorageClass)
        smb-pv-pvc creates a PV and PVC (This still checks for iX values, but only when running in SCALE)
        nfs-pv-pvc creates a PV and PVC (This still checks for iX values, but only when running in SCALE)
      */}}
      {{/* Only spawn PVC if its enabled and any type of "pvc" */}}
      {{- if and (mustHas $objectData.type (list "smb-pv-pvc" "nfs-pv-pvc" "ix-zfs-pvc" "pvc")) (not $objectData.existingClaim) -}}
        {{- $objectName := (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $) $name) -}}
        {{/* Perform validations */}}
        {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
        {{/* Set the name of the secret */}}
        {{- $_ := set $objectData "name" $objectName -}}
        {{- $_ := set $objectData "shortName" $name -}}
        {{- if eq $objectData.type "smb-pv-pvc" -}}
          {{ $_ := set $objectData "provisioner" "smb.csi.k8s.io" }}
          {{ $_ := set $objectData "driver" "smb.csi.k8s.io" }}
          {{/* TODO: Validate mountOptions */}}
          {{/* TODO: Create secret with creds */}}
          {{- include "ix.v1.common.class.pv" (dict "rootCtx" $ "objectData" $objectData) -}}

        {{- else if eq $objectData.type "nfs-pv-pvc" -}}
          {{ $_ := set $objectData "provisioner" "nfs.csi.k8s.io" }}
          {{ $_ := set $objectData "driver" "nfs.csi.k8s.io" }}

          {{/* Validate NFS CSI */}}
          {{- include "ix.v1.common.lib.storage.nfsCSI.validation" (dict "rootCtx" $ "objectData" $objectData) -}}

          {{/* TODO: Validate mountOptions */}}
          {{- include "ix.v1.common.class.pv" (dict "rootCtx" $ "objectData" $objectData) -}}


        {{- end -}}
        {{/* Call class to create the object */}}
        {{- include "ix.v1.common.class.pvc" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
