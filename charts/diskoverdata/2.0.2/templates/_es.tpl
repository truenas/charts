{{- define "es.workload" -}}
workload:
  elasticsearch:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        elasticsearch:
          enabled: true
          primary: true
          imageSelector: elasticSearchImage
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
            readOnlyRootFilesystem: false
          env:
            ELASTIC_PASSWORD:
              secretKeyRef:
                name: diskover-secret
                key: es-password
            http.port: 9200
            discovery.type: single-node
            node.name: diskoverdata
          probes:
            liveness:
              enabled: true
              type: exec
              command:
                - /bin/bash
                - -c
                - |
                  curl -s -H "Authorization: Basic $(base64 <<< "elastic:$ELASTIC_PASSWORD")" \
                    http://localhost:9200/_cluster/health?local=true
            readiness:
              enabled: true
              type: exec
              command:
                - /bin/bash
                - -c
                - |
                  curl -s -H "Authorization: Basic $(base64 <<< "elastic:$ELASTIC_PASSWORD")" \
                    http://localhost:9200/_cluster/health?local=true
            startup:
              enabled: true
              type: exec
              command:
                - /bin/bash
                - -c
                - |
                  curl -s -H "Authorization: Basic $(base64 <<< "elastic:$ELASTIC_PASSWORD")" \
                    http://localhost:9200/_cluster/health?local=true
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1000
                                                        "GID" 1000
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
