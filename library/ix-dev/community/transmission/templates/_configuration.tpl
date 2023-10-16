{{- define "transmission.configuration" -}}

{{/* Configmaps */}}
configmap:
  transmission-config:
    enabled: true
    data:
      TRANSMISSION__BIND_ADDRESS_IPV4: "0.0.0.0"
      TRANSMISSION__RPC_PORT: {{ .Values.transmissionNetwork.webPort | quote }}
      TRANSMISSION__PEER_PORT: {{ .Values.transmissionNetwork.peerPort | quote }}
{{- end -}}
