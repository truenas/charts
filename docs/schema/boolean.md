# Boolean Schema

## Example of boolean schema options

```yaml
- variable: boolean_variable
  label: Boolean Variable
  description: Description of boolean variable
  schema:
    type: boolean
    required: true
    editable: true
    immutable: true
    hidden: true
    default: true
```

Following attributes can be added to `boolean` schema to enforce validation when a chart release is being created/edited:
Those attributes are set in the schema during the chart development and are not user configurable.

| Attribute              |     Type     | Default | Description                                                                                                                                                                                                             |
| :--------------------- | :----------: | :-----: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `immutable`            |  `boolean`   | `false` | When set to true, the value of this variable cannot be changed after the chart is installed.                                                                                                                            |
| `required`             |  `boolean`   | `false` | When set to true, the value of this variable is required to be set to `true`, Useful when user is required to "accept" terms of use for example.                                                                        |
| `editable`             |  `boolean`   | `false` | When set to true, the value of this variable cannot be edited by the user. Useful if you want a user to see the value but not be able to edit.                                                                          |
| `hidden`               |  `boolean`   | `false` | When set to true, this variable is is hidden from the user.                                                                                                                                                             |
| `default`              |  `boolean`   | `false` | When set to a boolean, the value of this variable will be set to the specified value by default.                                                                                                                        |
| `show_if`              | `expression` |  unset  | When set to an [expression](show_if.md#expression-syntax) that evaluates to true, it will make the variable visible and effective. If it evaluates to false, it will be hidden and it won't be passed to the helm chart |
| `show_subquestions_if` |  `boolean`   |  unset  | When set to a value and the parent value matches, it will show the subquestions. Note that subquestion variables will be passed to the helm chart on the same level as the "parent" variable. It won't be nested.       |
| `subquestions`         |    `dict`    |  unset  | Define subquestion variables, following the usual schema per type, only difference is that you **can't** define `show_subquestions_if` under `subquestions`                                                             |
