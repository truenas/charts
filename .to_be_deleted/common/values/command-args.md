# Command / Args

| Key       |    Type     | Helm Template | Default | Description             |
| :-------- | :---------: | :-----------: | :-----: | :---------------------- |
| command   | list/string |      Yes      |  `[]`   | [command](#command)     |
| args      | list/string |      Yes      |  `[]`   | [args](#args)           |
| extraArgs | list/string |      Yes      |  `[]`   | [extraArgs](#extraargs) |

## command

Overrides the entrypoint of the container

---

Can be defined in:

- `.Values`.command
- `.Values.lifecycle.preStop`.command
- `.Values.lifecycle.postStart`.command
- `.Values.probes.[probe-name].exec`.command
- `.Values.initContainers.[container-name]`.command
- `.Values.systemContainers.[container-name]`.command
- `.Values.installContainers.[container-name]`.command
- `.Values.upgradeContainers.[container-name]`.command
- `.Values.additionalContainers.[container-name]`.command
- `.Values.additionalContainers.[container-name].lifecycle.preStop`.command
- `.Values.additionalContainers.[container-name].lifecycle.postStart`.command
- `.Values.jobs.[job-name].podSpec.containers.[container-name].[container-name]`.command

---

Examples:

```yaml
# String / Single command
command: ./custom-script.sh
# String / Single command (tpl)
command: "{{ .Values.customCommand }}"

# List
command:
  - /bin/sh
  - -c
  - |
    echo "Doing things..."
# List (tpl)
command:
  - /path/to/executable
  - --port
  - "{{ .Values.service.main.ports.main.port }}"
```

---

---

## args

Specify a single or a list of arguments for the entrypoint of the container.

---

Can be defined in:

- `.Values`.args
- `.Values.additionalContainers.[container-name]`.args
- `.Values.initContainers.[container-name]`.args
- `.Values.installContainers.[container-name]`.args
- `.Values.upgradeContainers.[container-name]`.args
- `.Values.systemContainers.[container-name]`.args
- `.Values.jobs.[job-name].podSpec.containers.[container-name].[container-name]`.args

---

Examples:

```yaml
# String / Single args
args: worker
# String / Single arg (tpl)
arg: "{{ .Values.mode }}"

# List
arg:
  - --port
  - 8080
# List (tpl)
arg:
  - --port
  - "{{ .Values.service.main.ports.main.port }}"
```

---

---

## extraArgs

Specify a single or a list of arguments that will be appended to [args](#args)
This is useful for exposing it on SCALE GUI, so users can append
arguments on top of the ones defined from the chart developer

---

Can be defined in:

- `.Values`.extraArgs
- `.Values.additionalContainers.[container-name]`.extraArgs
- `.Values.initContainers.[container-name]`.extraArgs
- `.Values.installContainers.[container-name]`.extraArgs
- `.Values.upgradeContainers.[container-name]`.extraArgs
- `.Values.systemContainers.[container-name]`.extraArgs
- `.Values.jobs.[job-name].podSpec.containers.[container-name].[container-name]`.extraArgs

---

Examples:

```yaml
# String / Single args
extraArgs: some_extra_arg
# String / Single arg (tpl)
extraArgs: "{{ .Values.some_key }}"

# List
extraArgs:
  - --photos_path
  - /path/to/photos
# List (tpl)
extraArgs:
  - --photos_path
  - "{{ .Values.persistence.photos.mountPath }}"
```

---

---

Kubernetes Documentation:

- [Command / Args](https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#define-a-command-and-arguments-when-you-create-a-pod)
