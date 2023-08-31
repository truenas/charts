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
          {{/* Validate SMB CSI */}}
          {{- include "ix.v1.common.lib.storage.smbCSI.validation" (dict "rootCtx" $ "objectData" $objectData) -}}

          {{- $size := $objectData.size | default $.Values.fallbackDefaults.pvcSize -}}
          {{- $hashValues := (printf "%s-%s-%s" $size $objectData.server $objectData.share) -}}
          {{- if $objectData.domain -}}
            {{- $hashValues = (printf "%s-%s" $hashValues $objectData.domain) -}}
          {{- end -}}

          {{/* Create a unique name taking into account server and share,
              without this, changing one of those values is not possible */}}
          {{- $hash := adler32sum $hashValues -}}
          {{- $_ := set $objectData "name" (printf "%s-%v" $objectName $hash) -}}

          {{- $_ := set $objectData "provisioner" "smb.csi.k8s.io" -}}
          {{- $_ := set $objectData "driver" "smb.csi.k8s.io" -}}
          {{- $_ := set $objectData "storageClass" $objectData.name -}}

          {{/* Create secret with creds */}}
          {{- $secretData := (dict
                                "name" $objectData.name
                                "labels" ($objectData.labels | default dict)
                                "annotations" ($objectData.annotations | default dict)
                                "data" (dict "username" $objectData.username "password" $objectData.password)
                              ) -}}
          {{- with $objectData.domain -}}
            {{- $_ := set $secretData.data "domain" . -}}
          {{- end -}}
          {{- include "ix.v1.common.class.secret" (dict "rootCtx" $ "objectData" $secretData) -}}

          {{/* Create the PV */}}
          {{- include "ix.v1.common.class.pv" (dict "rootCtx" $ "objectData" $objectData) -}}

        {{- else if eq $objectData.type "nfs-pv-pvc" -}}
          {{/* Validate NFS CSI */}}
          {{- include "ix.v1.common.lib.storage.nfsCSI.validation" (dict "rootCtx" $ "objectData" $objectData) -}}

          {{- $size := $objectData.size | default $.Values.fallbackDefaults.pvcSize -}}
          {{- $hashValues := (printf "%s-%s-%s" $size $objectData.server $objectData.share) -}}
          {{/* Create a unique name taking into account server and share,
              without this, changing one of those values is not possible */}}
          {{- $hash := adler32sum $hashValues -}}
          {{- $_ := set $objectData "name" (printf "%s-%v" $objectName $hash) -}}

          {{- $_ := set $objectData "provisioner" "nfs.csi.k8s.io" -}}
          {{- $_ := set $objectData "driver" "nfs.csi.k8s.io" -}}
          {{- $_ := set $objectData "storageClass" $objectData.name -}}

          {{/* Create the PV */}}
          {{- include "ix.v1.common.class.pv" (dict "rootCtx" $ "objectData" $objectData) -}}
        {{- end -}}

        {{/* Call class to create the object */}}
        {{- include "ix.v1.common.class.pvc" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
