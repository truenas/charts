{{- define "chia.plotDirs" -}}
  {{- $plotDirs := list "/plots" -}}
  {{- range $vol := .Values.chiaStorage.additionalVolumes -}}
    {{- if $vol.isPlotDir -}}
      {{- $plotDirs = mustAppend $plotDirs $vol.mountPath -}}
    {{- end -}}

  {{- end -}}
  {{- join ":" $plotDirs -}}
{{- end -}}

{{- define "chia.keyfile" -}}
  {{ print "/plots/keyfile" }}
{{- end -}}
