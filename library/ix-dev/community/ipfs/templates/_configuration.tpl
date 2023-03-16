{{- define "ipfs.configuration" -}}
{{/* Default Swarm Addresses https://github.com/ipfs/kubo/blob/master/docs/config.md#addressesswarm */}}
{{ $swarmAddressesList := (list
      (printf "/ip4/0.0.0.0/tcp/%v" .Values.ipfsNetwork.swarmPort)
      (printf "/ip6/::/tcp/%v" .Values.ipfsNetwork.swarmPort)
      (printf "/ip4/0.0.0.0/udp/%v/quic" .Values.ipfsNetwork.swarmPort)
      (printf "/ip4/0.0.0.0/udp/%v/quic-v1" .Values.ipfsNetwork.swarmPort)
      (printf "/ip4/0.0.0.0/udp/%v/quic-v1/webtransport" .Values.ipfsNetwork.swarmPort)
      (printf "/ip6/::/udp/%v/quic" .Values.ipfsNetwork.swarmPort)
      (printf "/ip6/::/udp/%v/quic-v1" .Values.ipfsNetwork.swarmPort)
      (printf "/ip6/::/udp/%v/quic-v1/webtransport" .Values.ipfsNetwork.swarmPort)
) }}

{{ $swarmAddresses := printf "[ \"%s\" ]" (join "\", \"" $swarmAddressesList) }}

{{/* Default API Address https://github.com/ipfs/kubo/blob/master/docs/config.md#addressesapi */}}
{{ $apiAddresses := printf "/ip4/0.0.0.0/tcp/%v" .Values.ipfsNetwork.apiPort }}
{{/* Default Gateway Address https://github.com/ipfs/kubo/blob/master/docs/config.md#addressesgateway */}}
{{ $gatewayAddresses := printf "/ip4/0.0.0.0/tcp/%v" .Values.ipfsNetwork.gatewayPort }}
{{ $allowOrigins := "[ \"*\" ]" }}
{{ $allowMethods := "[ \"PUT\", \"POST\" ]" }}


{{/* Configmaps */}}
configmap:
  config-script:
    enabled: true
    data:
      init-config.sh: |
        #!/bin/sh
        set -e

        if [ ! -f /data/ipfs/config ]; then
          # Create the IPFS config file
          echo "Initializing IPFS"
          ipfs init
        fi

        # Configure the Addresses.API
        echo "Configuring the Addresses.API to {{ $apiAddresses }}"
        ipfs config Addresses.API {{ $apiAddresses }}

        # Configure the Addresses.Gateway
        echo "Configuring the Addresses.Gateway to {{ $gatewayAddresses }}"
        ipfs config Addresses.Gateway {{ $gatewayAddresses }}

        # Configure the Addresses.Swarm
        echo "Configuring the Addresses.Swarm to {{ $swarmAddresses | squote }}"
        ipfs config Addresses.Swarm --json {{ $swarmAddresses | squote }}

        # Configure the API.HTTPHeaders.Access-Control-Allow-Origin
        echo "Configuring the API.HTTPHeaders.Access-Control-Allow-Origin to {{ $allowOrigins | squote }}"
        ipfs config API.HTTPHeaders.Access-Control-Allow-Origin --json {{ $allowOrigins | squote }}

        # Configure the API.HTTPHeaders.Access-Control-Allow-Methods
        echo "Configuring the API.HTTPHeaders.Access-Control-Allow-Methods to {{ $allowMethods | squote }}"
        ipfs config API.HTTPHeaders.Access-Control-Allow-Methods --json {{ $allowMethods | squote }}

        echo "Finished configuring IPFS"
{{- end -}}
