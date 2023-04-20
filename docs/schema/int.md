# Int Schema

## Example of int schema options

```yaml
- variable: int_variable
  label: Int Variable
  description: Description of int variable
  schema:
    type: int
    required: true
    editable: true
    immutable: true
    hidden: true
    "null": true
    min: 5
    max: 12
    valid_chars: "[0-9]{3}"
    default: 10
```

Following attributes can be added to `int` schema to enforce validation when a chart release is being created/edited:
Those attributes are set in the schema during the chart development and are not user configurable.

| Attribute              |     Type     | Default | Description                                                                                                                                                                                                             |
| :--------------------- | :----------: | :-----: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `immutable`            |  `boolean`   | `false` | When set to true, the value of this variable cannot be changed after the chart is installed.                                                                                                                            |
| `required`             |  `boolean`   | `false` | When set to true, the value of this variable is required and cannot be empty.                                                                                                                                           |
| `editable`             |  `boolean`   | `false` | When set to true, the value of this variable cannot be edited by the user. Useful if you want a user to see the value but not be able to edit.                                                                          |
| `hidden`               |  `boolean`   | `false` | When set to true, this variable is is hidden from the user.                                                                                                                                                             |
| `"null"`               |  `boolean`   | `false` | When set to true, this variable can be `null`.                                                                                                                                                                          |
| `min`                  |  `integer`   |  unset  | When set to a value greater than 0, the value of this variable cannot be smaller than the specified number.                                                                                                             |
| `max`                  |  `integer`   |  unset  | When set to a value greater than 0, the value of this variable larger than the specified number.                                                                                                                        |
| `valid_chars`          |   `string`   |  unset  | When set to a regex, the value of this variable must conform to the specified regex. Underneath the [Python3 Regex Library](https://docs.python.org/3/library/re.html) is used.                                         |
| `default`              |    `int`     |  unset  | When set to an int, the value of this variable will be set to the specified value by default.                                                                                                                           |
| `show_if`              | `expression` |  unset  | When set to an [expression](show_if.md#expression-syntax) that evaluates to true, it will make the variable visible and effective. If it evaluates to false, it will be hidden and it won't be passed to the helm chart |
| `show_subquestions_if` |    `int`     |  unset  | When set to a value and the parent value matches, it will show the subquestions. Note that subquestion variables will be passed to the helm chart on the same level as the "parent" variable. It won't be nested.       |
| `subquestions`         |    `dict`    |  unset  | Define subquestion variables, following the usual schema per type, only difference is that you **can't** define `show_subquestions_if` under `subquestions`                                                             |
