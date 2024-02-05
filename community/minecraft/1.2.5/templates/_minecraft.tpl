{{- define "minecraft.workload" -}}
workload:
  minecraft:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.mcNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.mcID.group }}
      containers:
        minecraft:
          enabled: true
          primary: true
          tty: true
          stdin: true
          imageSelector: {{ .Values.mcConfig.imageSelector }}
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            readOnlyRootFilesystem: false
            runAsNonRoot: false
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETUID
                - SETGID
          fixedEnv:
            PUID: {{ .Values.mcID.user }}
          envFrom:
            - configMapRef:
                name: minecraft-config
          {{ with .Values.mcConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command: mc-health
            readiness:
              enabled: true
              type: exec
              command: mc-health
            startup:
              enabled: true
              type: exec
              command: mc-health
              initialDelaySeconds: 120
{{/* Service */}}
service:
  minecraft:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: minecraft
    ports:
      server:
        enabled: true
        primary: true
        port: {{ .Values.mcNetwork.serverPort }}
        nodePort: {{ .Values.mcNetwork.serverPort }}
        targetSelector: minecraft
      rcon:
        enabled: {{ .Values.mcConfig.enableRcon }}
        port: {{ .Values.mcNetwork.rconPort }}
        nodePort: {{ .Values.mcNetwork.rconPort }}
        targetSelector: minecraft

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    {{- include "minecraft.storage.ci.migration" (dict "storage" .Values.mcStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.mcStorage.data) | nindent 4 }}
    targetSelector:
      minecraft:
        minecraft:
          mountPath: /data
  {{- range $idx, $storage := .Values.mcStorage.additionalStorages }}
  {{ printf "mc-%v" (int $idx) }}:
    enabled: true
    {{- include "minecraft.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      minecraft:
        minecraft:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "minecraft.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
