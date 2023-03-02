# Dict Schema

## Example of dict schema options

```yaml
- variable: dict_variable
  label: Dict Variable
  description: Description of dict variable
  schema:
    type: dict
    additional_attrs: true
    show_if: [[ "some_variable", "=", "some_value" ]]
    attrs:
      - variable: string_variable
        label: String Variable
        description: Description of string variable
        schema:
          type: string
```

Following attributes can be added to `dict` schema to enforce validation when a chart release is being created/edited:
Those attributes are set in the schema during the chart development and are not user configurable.

| Attribute          |     Type     | Default | Description                                                                                                                                                                                                             |
| :----------------- | :----------: | :-----: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `additional_attrs` |  `boolean`   | `false` | When set to `true`, allows additional variables to be added.                                                                                                                                                            |
| `attrs`            |    `dict`    |  unset  | Define variables within the dict                                                                                                                                                                                        |
| `show_if`          | `expression` |  unset  | When set to an [expression](show_if.md#expression-syntax) that evaluates to true, it will make the variable visible and effective. If it evaluates to false, it will be hidden and it won't be passed to the helm chart |
