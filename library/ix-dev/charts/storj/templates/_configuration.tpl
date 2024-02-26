{{- define "storj.configuration" -}}
secret:
  storj:
    enabled: true
    data:
      authToken: {{ .Values.storjConfig.authToken | quote }}
      wallet: {{ .Values.storjConfig.wallet | quote }}
configmap:
  storj:
    enabled: true
    data:
      init_config.sh: |
        #!/bin/sh
        echo "Checking for identity certificate"
        if ! [ -f ${DEFAULT_CERT_PATH} ] && ! [ -f ${DEFAULT_IDENTITY_CERT_PATH} ]; then
          echo "Downloading identity generator tool"
          curl -L https://github.com/storj/storj/releases/latest/download/identity_linux_amd64.zip -o identity_linux_amd64.zip
          unzip -o identity_linux_amd64.zip
          chmod +x identity
          echo "Generating identity certificate"
          ./identity create storagenode
          echo "Authorizing identity certificate"
          ./identity authorize storagenode ${AUTH_KEY}
          echo "Storagenode identity certificate generated"
          chown -R {{ .Values.storjRunAs.user }}:{{ .Values.storjRunAs.group }} {{ template "storj.idPath" }}
        fi
{{- end -}}

{{- define "storj.args" -}}
  {{- $wallets := list -}}
  {{- if .Values.storjConfig.wallets.zkSync -}}
    {{- $wallets = mustAppend $wallets "zksync" -}}
  {{- end -}}

  {{- if .Values.storjConfig.wallets.zkSyncEra -}}
    {{- $wallets = mustAppend $wallets "zksync-era" -}}
  {{- end -}}

{{- if $wallets -}}
args:
  - --operator.wallet-features={{ join "," $wallets }}
{{- end -}}

{{- end -}}

{{- define "storj.idPath" -}}
  {{- print "/root/.local/share/storj/identity/storagenode" -}}
{{- end -}}
