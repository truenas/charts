{{- define "transmission.configuration" -}}
configmap:
  transmission-config:
    enabled: true
    data:
      TRANSMISSION__RPC_ENABLED: "true"
      TRANSMISSION__RPC_BIND_ADDRESS: "0.0.0.0"
      TRANSMISSION__RPC_PORT: {{ .Values.transmissionNetwork.webPort | quote }}
      TRANSMISSION__PEER_PORT: {{ .Values.transmissionNetwork.peerPort | quote }}
      TRANSMISSION__DOWNLOAD_DIR: {{ .Values.transmissionStorage.downloadDir }}
      TRANSMISSION__INCOMPLETE_DIR_ENABLED: {{ .Values.transmissionStorage.enableIncompleteDir | quote }}
      TRANSMISSION__INCOMPLETE_DIR: {{ .Values.transmissionStorage.incompleteDir }}
{{- end -}}
