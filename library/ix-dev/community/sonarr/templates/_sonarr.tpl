{{- define "sonarr.workload" -}}
workload:
  sonarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.sonarrNetwork.hostNetwork }}
      containers:
        sonarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.sonarrRunAs.user }}
            runAsGroup: {{ .Values.sonarrRunAs.group }}
          env:
            SONARR__PORT: {{ .Values.sonarrNetwork.webPort }}
            SONARR__INSTANCE_NAME: {{ .Values.sonarrConfig.instanceName }}
          {{ with .Values.sonarrConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: "{{ .Values.sonarrNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.sonarrNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.sonarrNetwork.webPort }}"
              path: /ping

{{/* Service */}}
service:
  sonarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: sonarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.sonarrNetwork.webPort }}
        nodePort: {{ .Values.sonarrNetwork.webPort }}
        targetSelector: sonarr

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    {{- include "sonarr.storage.ci.migration" (dict "storage" .Values.sonarrStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.sonarrStorage.config) | nindent 4 }}
    targetSelector:
      sonarr:
        sonarr:
          mountPath: /config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      sonarr:
        sonarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.sonarrStorage.additionalStorages }}
  {{ printf "sonarr-%v:" (int $idx) }}
    enabled: true
    {{- include "sonarr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      sonarr:
        sonarr:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "sonarr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
