# Notes

| Key          |   Type   | Required | Helm Template |  Default  | Description                                              |
| :----------- | :------: | :------: | :-----------: | :-------: | :------------------------------------------------------- |
| notes        |  `dict`  |    ❌    |      ❌       | See below | Define values for NOTES.txt                              |
| notes.header | `string` |    ❌    |      ✅       | See below | Define header                                            |
| notes.custom | `string` |    ❌    |      ✅       | See below | Define custom message, this go between header and footer |
| notes.footer | `string` |    ❌    |      ✅       | See below | Define footer                                            |

---

Appears in:

- `.Values.notes`

---

Default:

```yaml
notes:
  header: |
    # Welcome to SCALE
    Thank you for installing <{{ .Chart.Name }}>.
  custom: ""
  footer: |
    # Documentation
    Documentation for this chart can be found at ...
    # Bug reports
    If you find a bug in this chart, please file an issue at ...
```

---

Examples:

```yaml
notes:
  custom: |
    This is a custom message
```
