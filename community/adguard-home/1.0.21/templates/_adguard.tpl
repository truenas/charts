{{- define "adguard.workload" -}}
workload:
  adguard:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      # Host network is pretty much a requirement for apps like this.
      # Because NodePort can't bind ports like 53(DNS) or 67(DHCP)
      # and the majority of devices do not have option to change the port.
      hostNetwork: true
      containers:
        adguard:
          enabled: true
          primary: true
          imageSelector: image
          # Args are copied from the official docker image
          # So we can also specify the port.
          # If we dont specify the port here, AdGuardHome
          # will start initially at port 3000 and after
          # the setup wizard is completed it will switch
          # to user specified port.
          args:
          # If appVersion is 0.107.29 or above add this flag
          # AND appVersion is below 0.107.34
          {{- if and
            (semverCompare "~0.107.29" (.Values.image.tag | replace "v" ""))
            (not (semverCompare "~0.107.34" (.Values.image.tag | replace "v" ""))) }}
            - /opt/adguardhome/AdGuardHome
          {{- end }}
            - --no-check-update
            - --host
            - "0.0.0.0"
            - --config
            - /opt/adguardhome/conf/AdGuardHome.yaml
            - --work-dir
            - /opt/adguardhome/work
            - --port
            - {{ .Values.adguardNetwork.webPort | quote }}
            # Setup wizard shows an option to select the port that AdGuardHome
            # Web UI will listen on. If the user selects anything other than the `webPort`,
            # container will reload its new configuration and listen to the user specified port.
            # But user won't have access to it because the port is not exposed. Few seconds later
            # probes will kill the container and restart it with the correct `webPort` port.
          securityContext:
            # FIXME: It might be able to run rootless, probably blocked by:
            # https://github.com/AdguardTeam/AdGuardHome/issues/4681
            runAsNonRoot: false
            runAsUser: 0
            runAsGroup: 0
            capabilities:
              add:
                - NET_BIND_SERVICE
                {{ if .Values.adguardNetwork.enableDHCP }}
                - NET_RAW
                {{ end }}
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
