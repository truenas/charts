# Service Links

## Key: enableServiceLinks

Info:

- Type: `boolean`
- Default: `false`
- Helm Template: ❌

Can be defined in:

- `.Values`.enableServiceLinks
- `.Values.jobs.[job-name].podSpec`.enableServiceLinks

---

EnableServiceLinks indicates whether information about services should be
injected into pod's environment variables, matching the syntax of Docker links.

We default it to false, otherwise kubernetes will inject envs for each
of the active services. Which can be a lot.
> Disabling this does NOT affect DNS usage.

Examples:

```yaml
enableServiceLinks: true
```
