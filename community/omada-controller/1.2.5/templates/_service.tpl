{{- define "omada.service" -}}
service:
  omada:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: omada
    ports:
      manage-https:
        enabled: true
        primary: true
        port: {{ .Values.omadaNetwork.manageHttpsPort }}
        nodePort: {{ .Values.omadaNetwork.manageHttpsPort }}
        targetSelector: omada
      manage-http:
        enabled: true
        port: {{ .Values.omadaNetwork.manageHttpPort }}
        nodePort: {{ .Values.omadaNetwork.manageHttpPort }}
        targetSelector: omada

  omada-portal:
    enabled: true
    type: NodePort
    targetSelector: omada
    ports:
      portal-https:
        enabled: true
        primary: true
        port: {{ .Values.omadaNetwork.portalHttpsPort }}
        nodePort: {{ .Values.omadaNetwork.portalHttpsPort }}
        targetSelector: omada
      portal-http:
        enabled: true
        port: {{ .Values.omadaNetwork.portalHttpPort }}
        nodePort: {{ .Values.omadaNetwork.portalHttpPort }}
        targetSelector: omada

  omada-discovery:
    enabled: true
    type: NodePort
    targetSelector: omada
    ports:
      app-discovery:
        enabled: true
        primary: true
        port: {{ .Values.omadaNetwork.appDiscoveryPort }}
        nodePort: {{ .Values.omadaNetwork.appDiscoveryPort }}
        targetSelector: omada
      discovery:
        enabled: true
        port: {{ .Values.omadaNetwork.discoveryPort }}
        nodePort: {{ .Values.omadaNetwork.discoveryPort }}
        targetSelector: omada

  omada-devices:
    enabled: true
    type: NodePort
    targetSelector: omada
    ports:
      managerv1:
        enabled: true
        primary: true
        port: {{ .Values.omadaNetwork.managerV1Port }}
        nodePort: {{ .Values.omadaNetwork.managerV1Port }}
        targetSelector: omada
      adoptv1:
        enabled: true
        port: {{ .Values.omadaNetwork.adoptV1Port }}
        nodePort: {{ .Values.omadaNetwork.adoptV1Port }}
        targetSelector: omada
      upgradev1:
        enabled: true
        port: {{ .Values.omadaNetwork.upgradeV1Port }}
        nodePort: {{ .Values.omadaNetwork.upgradeV1Port }}
        targetSelector: omada
      managerv2:
        enabled: true
        port: {{ .Values.omadaNetwork.managerV2Port }}
        nodePort: {{ .Values.omadaNetwork.managerV2Port }}
        targetSelector: omada
{{- end -}}
