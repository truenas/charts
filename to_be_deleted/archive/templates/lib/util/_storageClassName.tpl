{{/* Returns the storageClassname */}}
{{- define "ix.v1.common.storage.storageClassName" -}}
  {{- $persistence := .persistence -}}
  {{- $root := .root -}}

  {{/*
    If a storage class is defined on a persistence object:
      "-" returns "", which means requesting a PV without class
      "SCALE-ZFS" returns the value set on Values.globalDefaults.scaleZFSStorageClass
      else return the defined storageClass
    Else if there is a storageClass defined in Values.globalDefaults.storageClass, return this
    In any other case, return nothing
  */}}

  {{- if $persistence.storageClass -}}
    {{- $className := tpl $persistence.storageClass $root -}}
    {{- if eq "-" $className -}}
      {{- print "\"\"" -}}
    {{- else if eq "SCALE-ZFS" $className -}} {{/* Later, if we have more storage classes we add another else if (eg SCALE-SMB) */}}
      {{- if not $root.Values.globalDefaults.scaleZFSStorageClass -}}
        {{- fail "A storageClass must be defined in globalDefaults.scaleZFSStorageClass" -}}
      {{- end -}}
      {{- print (tpl $root.Values.globalDefaults.scaleZFSStorageClass $root) -}}
    {{- else -}}
      {{- print $className -}}
    {{- end -}}
  {{- else if $root.Values.ixChartContext -}}
    {{- print (tpl $root.Values.global.ixChartContext.storageClassName $root) -}}
  {{- else if $root.Values.globalDefaults.storageClass -}}
    {{- print $root.Values.globalDefaults.storageClass -}}
  {{- end -}}
{{- end -}}
