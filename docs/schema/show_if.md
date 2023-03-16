# Show if

`show_if` can only access variables that are defined in the same level as the variable that has `show_if` defined.

## Expression syntax

`[[ "variable_name", "operator", "value" ]]`

| Operator | Description                                                     | Example                                  |
| :------: | :-------------------------------------------------------------- | :--------------------------------------- |
|   `=`    | Value of `variable_name` is equal to "value"                    | `[[ "variable_name", "=", "value" ]]`    |
|   `!=`   | Value of `variable_name` is not equal to "value"                | `[[ "variable_name", "!=", "value" ]]`   |
|   `>`    | Value of `variable_name` is greater than "value"                | `[[ "variable_name", ">", "10" ]]`       |
|   `>=`   | Value of `variable_name` is greater or equal to "value"         | `[[ "variable_name", ">=", "10" ]]`      |
|   `<`    | Value of `variable_name` is less than "value"                   | `[[ "variable_name", "<", "10" ]]`       |
|   `<=`   | Value of `variable_name` is less or equal than "value"          | `[[ "variable_name", "<=", "10" ]]`      |
|   `in`   | Value of `variable_name` is contained in "value"                | `[[ "variable_name", "in", "value" ]]`   |
|  `nin`   | Value of `variable_name` is **not** contained in "value"        | `[[ "variable_name", "nin", "value" ]]`  |
|  `rin`   | Value of `variable_name` includes "value"                       | `[[ "variable_name", "rin", "value" ]]`  |
|  `rnin`  | Value of `variable_name` does **not** include "value"           | `[[ "variable_name", "rnin", "value" ]]` |
|   `^`    | Value of `variable_name` starts with "value"                    | `[[ "variable_name", "^", "value" ]]`    |
|   `!^`   | Value of `variable_name` does not start with "value"            | `[[ "variable_name", "!^", "value" ]]`   |
|   `$`    | Value of `variable_name` ends with "value"                      | `[[ "variable_name", "$", "value" ]]`    |
|   `!$`   | Value of `variable_name` does not end with "value"              | `[[ "variable_name", "!$", "value" ]]`   |
|   `~`    | Value of `variable_name` matches the regular expression "value" | `[[ "variable_name", "~", "value" ]]`    |

Examples:

```yaml
- variable: variable1
  label: Variable 1
  schema:
    type: string
    default: "some value"
- variable: variable2
  label: Variable 2
  schema:
    type: string
    show_if: [["variable2", "=", "some value"]]
```
