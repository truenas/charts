# RBAC

| Key                                      |   Type    | Required |   Helm Template    | Default | Description                                                               |
| :--------------------------------------- | :-------: | :------: | :----------------: | :-----: | :------------------------------------------------------------------------ |
| rbac                                     |  `dict`   |    ❌    |         ❌         |  `{}`   | Define the rbac as dicts                                                  |
| rbac.[rbac-name]                         |  `dict`   |    ✅    |         ❌         |  `{}`   | Holds rbac definition                                                     |
| rbac.[rbac-name].enabled                 | `boolean` |    ✅    |         ❌         | `false` | Enables or Disables the rbac                                              |
| rbac.[rbac-name].primary                 | `boolean` |    ❌    |         ❌         | `false` | Sets the rbac as primary                                                  |
| rbac.[rbac-name].clusterWide             | `boolean` |    ❌    |         ❌         | `false` | Sets the rbac as cluster wide (ClusterRole, ClusterRoleBinding)           |
| rbac.[rbac-name].labels                  |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional labels for rbac                                                |
| rbac.[rbac-name].annotations             |  `dict`   |    ❌    | ✅ (On value only) |  `{}`   | Additional annotations for rbac                                           |
| rbac.[rbac-name].allServiceAccounts      | `boolean` |    ❌    |         ❌         |         | Whether to assign all service accounts or not to the (Cluster)RoleBinding |
| rbac.[rbac-name].serviceAccounts         |  `list`   |    ❌    |         ❌         |  `[]`   | Define the service account(s) to assign the (Cluster)RoleBinding          |
| rbac.[rbac-name].rules                   |  `list`   |    ✅    |         ❌         |  `[]`   | Define the `rules` for the (Cluster)Role                                  |
| rbac.[rbac-name].rules.apiGroups         |  `list`   |    ✅    |         ❌         |  `[]`   | Define the `apiGroups` list for the `rules` for the (Cluster)Role         |
| rbac.[rbac-name].rules.apiGroups.[entry] | `string`  |    ✅    |         ✅         |         | Entry of the `apiGroups`                                                  |
| rbac.[rbac-name].rules.resources         |  `list`   |    ✅    |         ❌         |  `[]`   | Define the `resources` list for the `rules` for the (Cluster)Role         |
| rbac.[rbac-name].rules.resources.[entry] | `string`  |    ✅    |         ✅         |         | Entry of the `resources`                                                  |
| rbac.[rbac-name].rules.verbs             |  `list`   |    ✅    |         ❌         |  `[]`   | Define the `verbs` list for the `rules` for the (Cluster)Role             |
| rbac.[rbac-name].rules.verbs.[entry]     | `string`  |    ✅    |         ✅         |         | Entry of the `verbs`                                                      |
| rbac.[rbac-name].subjects                |  `list`   |    ❌    |         ❌         |  `[]`   | Define `subjects` for (Cluster)RoleBinding                                |
| rbac.[rbac-name].subjects.kind           | `string`  |    ✅    |         ✅         |  `""`   | Define the `kind` of `subjects` entry                                     |
| rbac.[rbac-name].subjects.name           | `string`  |    ✅    |         ✅         |  `""`   | Define the `name` of `subjects` entry                                     |
| rbac.[rbac-name].subjects.apiGroup       | `string`  |    ✅    |         ✅         |  `""`   | Define the `apiGroup` of `subjects` entry                                 |

> When `allServiceAccounts` is `true`, it will assign the all the serviceAccount(s) to the (Cluster)RoleBinding (`serviceAccounts` is ignored in this case)
> When `serviceAccounts` is a list, each entry is a string with the serviceAccount name that will be assigned to the (Cluster)RoleBinding. Can have multiple entries.
> When `serviceAccounts` is a empty, it will assign the primary serviceAccount to the primary rbac

---

Appears in:

- `.Values.rbac`

---

Naming scheme:

- Primary: `$FullName` (release-name-chart-name)
- Non-Primary: `$FullName-$RBACName` (release-name-chart-name-RBACName)

---

Examples:

```yaml
rbac:
  rbac-name:
    enabled: true
    primary: true
    clusterWide: true
    labels:
      key: value
      keytpl: "{{ .Values.some.value }}"
    annotations:
      key: value
      keytpl: "{{ .Values.some.value }}"
    allServiceAccounts: true
    rules:
      - apiGroups:
          - ""
        resources:
          - "{{ .Values.some.value }}"
        verbs:
          - get
          - "{{ .Values.some.value }}"
          - watch
    subjects:
      - kind: my-kind
        name: "{{ .Values.some.value }}"
        apiGroup: my-api-group

  other-rbac-name:
    enabled: true
    serviceAccounts:
      - service-account-name
    rules:
      - apiGroups:
          - ""
        resources:
          - pods
        verbs:
          - get
          - list
          - watch
    subjects:
      - kind: my-kind
        name: my-name
        apiGroup: my-api-group
```
