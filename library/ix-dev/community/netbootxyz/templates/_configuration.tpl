{{- define "nbxyz.configuration" -}}
configmap:
  init:
    enabled: true
    data:
      init.sh: |
        #!/bin/sh
        file="/defaults/default"
        echo "Configuring assets port to {{ .Values.nbxyzNetwork.assetsPort }}"
        # On first run the default file is copied to /config/nginx/site-confs/default
        # So we need to check if it exists and use that instead, as this is what nginx will use anyway
        if [ -f "/config/nginx/site-confs/default" ]; then
          file="/config/nginx/site-confs/default"
        fi
        sed -i 's/listen .*;/listen {{ .Values.nbxyzNetwork.assetsPort }};/' "$file"
        port=$(grep "listen {{ .Values.nbxyzNetwork.assetsPort }};" "$file")
        if [ -z "$port" ]; then
          echo "Failed to configure assets port"
          exit 1
        fi
        echo "Assets port configured successfully. Starting netboot.xyz..."
        # Run the actual entrypoint script
        sh start.sh
{{- end -}}
