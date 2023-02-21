# String Schema

## Example of string schema options

```yaml
schema:
  type: string
  private: true
  required: true
  immutable: true
  min_length: 5
  max_length: 12
  valid_chars: "[a-zA-Z0-9]$"
```

Following attributes can be added to `string` schema to enforce validation when a chart release is being created/edited:
Those attributes are set during the chart development and are not user configurable.

| Attribute     |   Type    | Default | Description                                                                                                                                                            |
| :------------ | :-------: | :-----: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `immutable`   | `boolean` | `false` | When set to true, the value of this variable cannot be changed after the chart is installed.                                                                           |
| `private`     | `boolean` | `false` | When set to true, each character of the value will appear as `*` in the UI. Useful for sensitive fields like passwords.                                                |
| `required`    | `boolean` | `false` | When set to true, the value of this variable is required and cannot be empty.                                                                                          |
| `min_length`  | `integer` |  unset  | When set to a value greater than 0, the value of this variable must be at least the specified characters.                                                              |
| `max_length`  | `integer` |  unset  | When set to a value greater than 0, the value of this variable must be at most the specified characters.                                                               |
| `valid_chars` | `string`  |  unset  | When set to a regex, the value of this variable must conform to the specified regex. Underneath the [Python3 Regex](https://docs.python.org/3/library/re.html) is used |
