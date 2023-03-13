{{- define "machinaris.config" -}}
machinaris:
  imageSelector: image
  blockchains: chia
  webPort: 8926
  apiPort: 8927
  networkPort: 8444
  farmerPort: 8447
flax:
  imageSelector: imageFlax
  availableModes: ["harvester"]
  blockchains: flax
  workerPort: 8928
  networkPort: 6888
  farmerPort: 6885
# apple:
#   workerPort: 8947
#   networkPort: 266666
#   farmerPort: 26667
# ballcoin:
#   workerPort: 8957
#   networkPort: 38888
#   farmerPort: 38891
# greenbtc:
#   workerPort: 8955
#   networkPort: 23333
#   farmerPort: 23332
{{- end -}}

{{- define "machinaris.plotDirs" -}}
  {{ $plotDirs := list }}
  {{ range $storage := .Values.machStorage.additionalVolumes }}
    {{ if eq $storage.usedFor "plots" }}
      {{ $plotDirs = mustAppend $plotDirs $storage.mountPath }}
    {{ end }}
  {{ end }}
  {{- $plotDirs | toJson -}}
{{- end -}}
