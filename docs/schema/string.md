# String Schema

## Example of string schema options

```yaml
- variable: string_variable
  label: String Variable
  description: Description of string variable
  schema:
    type: string
    private: true
    required: true
    editable: true
    immutable: true
    hidden: true
    min_length: 5
    max_length: 12
    default: "default_value"
    valid_chars: "[a-zA-Z0-9]$"
    enum:
      - value: "value1"
        description: "Description of value1"
    show_if: [["variable1", "=", "some value"]]
    show_subquestions_if: "value1"
    subquestions:
      - variable: subquestion1
        label: Subquestion 1
        schema:
          type: string
          required: true
```

Following attributes can be added to `string` schema to enforce validation when a chart release is being created/edited:
Those attributes are set in the schema during the chart development and are not user configurable.

| Attribute              |     Type     | Default | Description                                                                                                                                                                                                             |
| :--------------------- | :----------: | :-----: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `immutable`            |  `boolean`   | `false` | When set to true, the value of this variable cannot be changed after the chart is installed.                                                                                                                            |
| `private`              |  `boolean`   | `false` | When set to true, each character of the value will appear as `*` in the UI. Useful for sensitive fields like passwords.                                                                                                 |
| `required`             |  `boolean`   | `false` | When set to true, the value of this variable is required and cannot be empty.                                                                                                                                           |
| `editable`             |  `boolean`   | `false` | When set to true, the value of this variable cannot be edited by the user. Useful if you want a user to see the value but not be able to edit.                                                                          |
| `hidden`               |  `boolean`   | `false` | When set to true, this variable is is hidden from the user. Useful if you want to set a value that is populated from a `$ref` during the installation, but you don't want user to see the field.                        |
| `min_length`           |  `integer`   |  unset  | When set to a value greater than 0, the value of this variable must be at least the specified characters.                                                                                                               |
| `max_length`           |  `integer`   |  unset  | When set to a value greater than 0, the value of this variable must be at most the specified characters.                                                                                                                |
| `valid_chars`          |   `string`   |  unset  | When set to a regex, the value of this variable must conform to the specified regex. Underneath the [Python3 Regex Library](https://docs.python.org/3/library/re.html) is used.                                         |
| `default`              |   `string`   |  unset  | When set to a string, the value of this variable will be set to the specified value by default.                                                                                                                         |
| `enum`                 |   `array`    |  unset  | When set to an array of objects, the `value` of this variable must be one of the specified values. UI will have a dropdown with the values defined. `description` is what the user will see.                            |
| `show_if`              | `expression` |  unset  | When set to an [expression](show_if.md#expression-syntax) that evaluates to true, it will make the variable visible and effective. If it evaluates to false, it will be hidden and it won't be passed to the helm chart |
| `show_subquestions_if` |   `string`   |  unset  | When set to a value and the parent value matches, it will show the subquestions. Note that subquestion variables will be passed to the helm chart on the same level as the "parent" variable. It won't be nested.       |
| `subquestions`         |    `dict`    |  unset  | Define subquestion variables, following the usual schema per type, only difference is that you **can't** define `show_subquestions_if` under `subquestions`                                                             |

## Notes

- Having `required` set to true and an enum with empty `value` will not allow the user to save the form.
- Having `required` set to true and `editable` set to false will not allow the user to save the form.
- Having `editable` set to true and `immutable` set to true will only allow the user to edit the value once. (Same as `immutable` alone)
- Having `hidden` set to true, `required` set to true and `default` without a value will not allow the user to save the form.
