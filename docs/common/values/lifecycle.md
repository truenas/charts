# Lifecycle

| Key                         |    Type     | Helm Template | Default | Description                      |
| :-------------------------- | :---------: | :-----------: | :-----: | :------------------------------- |
| lifecycle                   |   object    |      Yes      |  `{}`   | [lifecycle](#lifecycle)          |
| lifecycle.preStop           |   object    |      Yes      |  `{}`   | [preStop](#prestop)              |
| lifecycle.preStop.command   | list/string |      Yes      |  `[]`   | [command](commands-args#command) |
| lifecycle.postStart         |   object    |      Yes      |  `{}`   | [postStart](#poststart)          |
| lifecycle.postStart.command | list/string |      Yes      |  `[]`   | [command](commands-args#command) |

## lifecycle

Specify hooks that will run on the container. Like `preStop` or `postStart`

---

Can be defined in:

- `.Values`.lifecycle
- `.Values.additionalContainers.[container-name]`.lifecycle

---

### preStop

Examples `preStop`:

```yaml
# String / Single command
lifecycle:
  preStop:
    command: ./custom-script.sh
# String / Single command (tpl)
lifecycle:
  preStop:
    command: "{{ .Values.customCommand }}"

# List
lifecycle:
  preStop:
    command:
      - /bin/sh
      - -c
      - |
        echo "Doing things..."
# List (tpl)
lifecycle:
  preStop:
    command:
      - /path/to/executable
      - --port
      - "{{ .Values.service.main.ports.main.port }}"
```

### postStart

Examples `postStart`:

```yaml
# String / Single command
lifecycle:
  postStart:
    command: ./custom-script.sh
# String / Single command (tpl)
lifecycle:
  postStart:
    command: "{{ .Values.customCommand }}"

# List
lifecycle:
  postStart:
    command:
      - /bin/sh
      - -c
      - |
        echo "Doing things..."
# List (tpl)
lifecycle:
  postStart:
    command:
      - /path/to/executable
      - --port
      - "{{ .Values.service.main.ports.main.port }}"
```

Kubernetes Documentation:

- [Lifecycle Hooks](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks)
