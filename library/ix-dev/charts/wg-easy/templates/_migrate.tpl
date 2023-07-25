{{- define "wgeasy.migrate" -}}
  {{/* If this key is missing we have already migrated */}}
  {{- if hasKey .Values "wgUDPPort" -}}

    {{/* Migrate Resources */}}
    {{- if not .Values.resources -}}
      {{- $_ := set .Values "resources" dict -}}
    {{- end -}}
    {{- if not .Values.resources.limits -}}
      {{- $_ := set .Values.resources "limits" dict -}}
    {{- end -}}

    {{- if hasKey .Values "cpuLimit" -}}
      {{- $_ := set .Values.resources.limits "cpu" .Values.cpuLimit -}}
    {{- end -}}
    {{- if hasKey .Values "memoryLimit" -}}
      {{- $_ := set .Values.resources.limits "memory" .Values.memoryLimit -}}
    {{- end -}}

    {{/* Migrate Network */}}
    {{- if not .Values.wgNetwork -}}
      {{- $_ := set .Values "wgNetwork" dict -}}
    {{- end -}}
    {{- $_ := set .Values.wgNetwork "udpPort" .Values.wgUDPPort -}}
    {{- $_ := set .Values.wgNetwork "webPort" .Values.webPort -}}
    {{- $_ := set .Values.wgNetwork "hostNetwork" .Values.hostNetwork -}}

    {{/* Migrate Config */}}
    {{- if not .Values.wgConfig -}}
      {{- $_ := set .Values "wgConfig" dict -}}
    {{- end -}}

    {{- if .Values.wgeasy -}}
      {{- $_ := set .Values.wgConfig "host" .Values.wgeasy.host -}}
      {{- $_ := set .Values.wgConfig "password" (.Values.wgeasy.password | default "") -}}
      {{- $_ := set .Values.wgConfig "keepAlive" .Values.wgeasy.keep_alive -}}
      {{- $_ := set .Values.wgConfig "clientMTU" .Values.wgeasy.client_mtu -}}
      {{- $_ := set .Values.wgConfig "clientAddressRange" .Values.wgeasy.client_address_range -}}
      {{- $_ := set .Values.wgConfig "clientDNSServer" .Values.wgeasy.client_dns_server -}}
      {{- $_ := set .Values.wgConfig "allowedIPs" .Values.wgeasy.allowed_ips -}}
      {{- $_ := set .Values.wgConfig "additionalEnvs" (.Values.environmentVariables | default list) -}}
    {{- end -}}

    {{/* Migrate Storage */}}
    {{- if not .Values.wgStorage -}}
      {{- $_ := set .Values "wgStorage" dict -}}
    {{- end -}}
    {{- if not .Values.wgStorage.config -}}
      {{- $_ := set .Values.wgStorage "config" dict -}}
    {{- end -}}

    {{- $conf := .Values.appVolumeMounts.config -}}
    {{- if $conf.hostPathEnabled -}}
      {{- $_ := set .Values.wgStorage "config" (dict
                                                "type" "hostPath"
                                                "hostPath" $conf.hostPath
                                              ) -}}
    {{- else -}}
      {{- $_ := set .Values.wgStorage "config" (dict
                                                "type" "ixVolume"
                                                "datasetName" $conf.datasetName
                                              ) -}}
    {{- end -}}

    {{- if not .Values.wgStorage.additionalStorages -}}
      {{- $_ := set .Values.wgStorage "additionaStorages" list -}}
    {{- end -}}

    {{- $items := .Values.wgStorage.additionalStorages -}}
    {{- range $item := .Values.extraAppVolumeMounts -}}
      {{- $items := mustAppend $items (dict
                                        "type" "hostPath"
                                        "mountPath" $item.mountPath
                                        "hostPath" $item.hostPath
                                        ) -}}
    {{- end -}}
    {{- $_ := set $.Values.wgStorage "additionalStorages" $items -}}
  {{- end -}}
{{- end -}}
