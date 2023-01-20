---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Deprecations template

The purpose of this template is to provide a means to prevent users from deploying the Helm chart, or updates to it, in what would be a broken state due to changes in how the chart is configured.

The design makes use of multiple templates, providing a modular method of declaring and managing deprecations. This is to aid in simplification of both development and maintenance.

## General concept

1. The last item in `templates/NOTES.txt` `include`s the `gitlab.deprecations` template from `templates/_deprecations.tpl`.
1. The `gitlab.deprecations` template `include`s further templates in the same file, collecting their outputs (strings) into a `list`.
1. Each individual template handles detection of now errant configuration, and outputs messages informing the user of how to address the change, or outputs nothing.
1. The `gitlab.deprecations` template checks if any messages were collected. If any messages were, it outputs them under a header of `DEPRECATIONS:` using the `fail` function.
1. The `fail` function results in the termination of the deployment process, preventing the user from deploying with a broken configuration.

## Template naming

Templates defined within, and used with this pattern should follow the naming convention of `gitlab.deprecation.*`. Replace `*` here with an informative name, such as `rails.appConfig` or `registry.storage` to denote what this deprecation is related to.

## Considerations in detection

The developer should be careful not to assume that a key, or parent key will exist. Judicious application of `if`, `hasKey` and `empty` are strongly recommended. It is just as likely for a single key to be present as it is for the entire property map to be missing several branches before that key. Helm _will_ complain if you attempt to access a property that does not exist within the map structure, generally in a vague manor. Save time, be explicit.

## Message format

All messages should have the following format:

```plaintext

chart:
    message
```

- The `if` statement preceding the message _should not_ trim the newline after it. (`}}` not `-}}`) This ensures the formatting and readability for the user.
- The message should declare which chart, relative to the global chart, that is affected. This helps the user understand where the property came from in the charts, and configuration properties. Example: `gitlab.webservice`, `minio`, `registry`.
- The message should inform the user of the property that has been altered / relocated / deprecated, and what action should be taken. Name the property relative to the affected chart. For example, `gitlab.webservice.minio.enabled` would be referenced as `webservice.enabled` because the chart affected by the deprecation is `gitlab.webservice`.

Example message:

```plaintext

gitlab.webservice:
    Chart-local configuration of Minio features has been moved to global. Please remove `gitlab.webservice.minio.enabled` from your properties, and set `global.minio.enabled` instead.
```

## Activating new deprecations

Once a template has been defined, and logic placed within it for the detection of affected properties, activating this new template is simple. Simple add a line beneath `add templates here` in the `gitlab.deprecations` template, according to the format presented.
