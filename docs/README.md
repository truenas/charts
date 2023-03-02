# Questions.yaml structure

This file have some top level attributes:

- Groups
- Portals
- Questions

## Groups

Groups can be defined to "group" questions together. This is useful when you have a lot of questions and want to split them into logical groups.

```yaml
groups:
  - name: "Group 1"
    description: "Description of group 1"
  - name: "Group 2"
    description: "Description of group 2"
```

- `name` is what will be used to reference the group in the `questions.yaml` file.
- `description` is a what will be displayed in the UI.

> Groups can only be referenced by the top level variables in `questions` attribute.

## Portals

Portals can be defined to display a button on the UI that will open a new tab to a specific URL.

```yaml
portals:
  button_name:
    protocols:
      - https
    host:
      - example.com
    ports:
      - 443
    path: /path/to/something
```

> You can define more than 1 portal. But the name of the portal must be unique.

Portals support some variables that can be used to dynamically generate the URL.

- `$variable-VARIABLE_NAME.NESTED_VARIABLE_NAME` will be replaced by the value of the variable `NESTED_VARIABLE_NAME` under the variable `VARIABLE_NAME`.
  (Variables are defined in the `questions` attribute)
- `$kubernetes-resource_configmap.RESOURCE_NAME.RESOURCE_KEY` will be replaced by the value of the key `RESOURCE_KEY` in the configmap named `RESOURCE_NAME`.
- `$node_ip` will be replaced by the IP of the node where the app is running.

## Questions

Questions are the main attribute of the `questions.yaml` file. It is used to define the questions that will be displayed in the UI.

```yaml
questions:
  - variable: variable_name
    label: Friendly Name
    group: "Group 1"
    description: "Description of the variable"
    schema:
      type: string
      default: "something"
```
