{{- define "adguard.workload" -}}
workload:
  adguard:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.adguardNetwork.hostNetwork }}
      containers:
        adguard:
          enabled: true
          primary: true
          imageSelector: image
          # Args are copied from the official docker image
          # So we can also specify the port.
          # If we dont specify the port here, AdGuardHome
          # will start initially at port 3000 and after
          # the setup wizard is completed it will switch.
          args:
            - --no-check-update
            - --host
            - "0.0.0.0"
            - --config
            - /opt/adguardhome/conf/AdGuardHome.yaml
            - --work-dir
            - /opt/adguardhome/work
            - --port
            - {{ .Values.adguardNetwork.webPort | quote }}
          securityContext:
            # FIXME: It should be able to run rootless, probably blocked by:
            # https://github.com/AdguardTeam/AdGuardHome/issues/4681
            runAsNonRoot: false
            runAsUser: 0
            runAsGroup: 0
            capabilities:
              add:
                - NET_BIND_SERVICE
          # FIXME: Switch to exec probe after this issue is solved, also note that healthcheck
          # is only available on "edge" tag, as of 27/03/2023
          # https://github.com/AdguardTeam/AdGuardHome/issues/3290#issuecomment-1485451976
          probes:
            liveness:
              enabled: true
              type: http
              path: /
              port: {{ .Values.adguardNetwork.webPort }}
            readiness:
              enabled: true
              type: http
              path: /
              port: {{ .Values.adguardNetwork.webPort }}
            startup:
              enabled: true
              type: http
              path: /
              port: {{ .Values.adguardNetwork.webPort }}
      {{/* # FIXME: Disabled until it can run as non-root
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.ipfsRunAs.user
                                                        "GID" .Values.ipfsRunAs.group
                                                        "type" "install") | nindent 8 }}
      */}}
{{/* Service */}}
service:
  adguard:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: adguard
    ports:
      adguard:
        enabled: true
        primary: true
        port: {{ .Values.adguardNetwork.webPort }}
        nodePort: {{ .Values.adguardNetwork.webPort }}
        targetSelector: adguard
  # TODO: Add services for DNS/DHCP

{{/* Persistence */}}
persistence:
  work:
    enabled: true
    type: {{ .Values.adguardStorage.work.type }}
    datasetName: {{ .Values.adguardStorage.work.datasetName | default "" }}
    hostPath: {{ .Values.adguardStorage.work.hostPath | default "" }}
    targetSelector:
      adguard:
        adguard:
          mountPath: /opt/adguardhome/work
        {{/* # FIXME: See above
        01-permissions:
          mountPath: /mnt/directories/work
        */}}
  conf:
    enabled: true
    type: {{ .Values.adguardStorage.conf.type }}
    datasetName: {{ .Values.adguardStorage.conf.datasetName | default "" }}
    hostPath: {{ .Values.adguardStorage.conf.hostPath | default "" }}
    targetSelector:
      adguard:
        adguard:
          mountPath: /opt/adguardhome/conf
        {{/* # FIXME: See above
        01-permissions:
          mountPath: /mnt/directories/conf
        */}}
{{- end -}}
