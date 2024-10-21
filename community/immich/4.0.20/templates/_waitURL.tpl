{{- define "immich.wait.init" -}}
{{- $url := .url }}
wait-url:
  enabled: true
  type: init
  imageSelector: bashImage
  command:
    - /bin/ash
    - -c
    - |
      echo "Pinging [{{ $url }}] until it is ready..."
      until wget --spider --quiet --timeout=3 --tries=1 "{{ $url }}"; do
        echo "Waiting for [{{ $url }}] to be ready..."
        sleep 2
      done
      echo "URL [{{ $url }}] is ready!"
{{- end -}}
