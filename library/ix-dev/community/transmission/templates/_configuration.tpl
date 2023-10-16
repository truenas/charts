{{- define "transmission.configuration" -}}
configmap:
  transmission-config:
    enabled: true
    data:
      TRANSMISSION__RPC_ENABLED: "true"
      TRANSMISSION__RPC_BIND_ADDRESS: "0.0.0.0"
      TRANSMISSION__RPC_PORT: {{ .Values.transmissionNetwork.webPort | quote }}
      TRANSMISSION__PEER_PORT: {{ .Values.transmissionNetwork.peerPort | quote }}
      TRANSMISSION__DOWNLOAD_DIR: "/downloads/complete"
      TRANSMISSION__INCOMPLETE_DIR: "/downloads/incomplete"
{{- end -}}
