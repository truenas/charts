{{- define "homepage.rbac" -}}
serviceAccount:
  homepage:
    enabled: true
    primary: true
    targetSelector:
      - homapage

rbac:
  homepage:
    enabled: true
    primary: true
    clusterWide: true
    serviceAccounts:
      - homepage
    rules:
      - apiGroups:
          - ""
        resources:
          - namespaces
          - pods
          - nodes
        verbs:
          - get
          - list
      - apiGroups:
          - extensions
          - networking.k8s.io
        resources:
          - ingresses
        verbs:
          - get
          - list
      - apiGroups:
          - traefik.containo.us
        resources:
          - ingressroutes
        verbs:
          - get
          - list
      - apiGroups:
          - metrics.k8s.io
        resources:
          - nodes
          - pods
        verbs:
          - get
          - list
{{- end -}}
