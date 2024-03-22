{{- define "netdata.rbac" -}}
serviceAccount:
  netdata:
    enabled: true
    primary: true

rbac:
  netdata:
    enabled: true
    primary: true
    clusterWide: true
    rules:
      - apiGroups:
          - ""
        resources:
          - pods
          - services
          - configmaps
          - secrets
        verbs:
          - get
          - list
          - watch
      - apiGroups:
          - ""
        resources:
          - namespaces
        verbs:
          - get
{{- end -}}
