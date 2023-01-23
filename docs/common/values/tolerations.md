# Toleration

## Key: tolerations

Info:

- Type: `list`
- Default: `[]`
- Helm Template:
  - tolerations.operator: ✅
  - tolerations.key: ✅
  - tolerations.effect: ✅
  - tolerations.value: ✅
  - tolerations.tolerationSeconds: ❌

Can be defined in:

- `.Values`.tolerations
- `.Values.jobs.[job-name].podSpec`.tolerations

---

Defines `tolerations` in Pod.
Allows pod to tolerate taints of a Node.

Examples:

```yaml
tolerations:
  - operator: Equal # "{{ .Values.some.path }}"
    # Required when operator is set to "Equal", otherwise Optional
    key: some-key # "{{ .Values.some.path }}"
    # Optional
    effect: NoExecute # "{{ .Values.some.path }}"
    # Dis-allowed when operator is set to "Exists", otherwise optional
    value: some-value
    # Optional
    tolerationSeconds: 10
```

Kubernetes Documentation:

- [Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
