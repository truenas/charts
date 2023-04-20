# List Schema

## Example of list schema options

```yaml
- variable: list_variable
  label: List Variable
  description: Description of list variable
  schema:
    type: list
    show_if: [["some_variable", "=", "some_value"]]
    default: ["value1", "value2"]
    # Single Variable (Passed to helm chart as a list of strings (or the type defined))
    items:
      - variable: string_variable
        label: String Variable
        description: Description of string variable
        schema:
          type: string
    # Dicts (Passed to helm chart as a list of dicts)
    items:
      - variable: dict_variable
        label: Dict Variable
        description: Description of dict variable
        schema:
          type: dict
          attrs:
            # Dict can have one or more variables
            - variable: string_variable
              label: String Variable
              description: Description of string variable
              schema:
                type: string
            - variable: int_variable
              label: Int Variable
              description: Description of int variable
              schema:
                type: int
```

Following attributes can be added to `list` schema to enforce validation when a chart release is being created/edited:
Those attributes are set in the schema during the chart development and are not user configurable.

| Attribute |     Type     | Default | Description                                                                                                                                                                                                                                |
| :-------- | :----------: | :-----: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `show_if` | `expression` |  unset  | When set to an [expression](show_if.md#expression-syntax) that evaluates to true, it will make the variable visible and effective. If it evaluates to false, it will be hidden and it won't be passed to the helm chart                    |
| `default` |    `list`    |  unset  | A default list of items can be defined in a `json` format. Single variable, multiple values: `["value1", "value2"]`. Dict variable, Multiple variables: `[{"var1": "val1", "var2": "val2"}, {"var1": "other_val1", "var2": "other_val2"}]` |
| `items`   |    `dict`    |  unset  | Define variables within the dict. This is like a template. Each time user clicks "Add" a form containing the defined variables will be presented                                                                                           |
