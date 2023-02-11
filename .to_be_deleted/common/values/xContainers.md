# xContainers

Order of container spawning:
`installContainers` -> `upgradeContainers` -> `systemContainers` -> `initContainers`

## key: additionalContainers

Info:

- Type: `dict`
- Default: `{}`
- Helm Template: ✅|❌
  - Supports almost every key the main container supports,
    except lifecycle hooks.

Can be defined in:

- `.Values`.additionalContainers

---

Defines containers that will run alongside the "main' container.

Examples:

```yaml
additionalContainers:
  container-name:
    enabled: true
    imageSelector: image # The name of the image dict to pull repo, tag, pullPolicy
    env:
      key: value
```

---
---

## key: installContainers

Info:

- Type: `dict`
- Default: `{}`
- Helm Template: ✅|❌
  - Supports almost every key the main container supports,
    except lifecycle hooks and probes

Can be defined in:

- `.Values`.installContainers

---

Defines containers that will run only at the installation of a Chart,
before the main container.

Examples:

```yaml
installContainers:
  container-name:
    enabled: true
    imageSelector: image # The name of the image dict to pull repo, tag, pullPolicy
    env:
      key: value
```

---
---

## key: upgradeContainers

Info:

- Type: `dict`
- Default: `{}`
- Helm Template: ✅|❌
  - Supports almost every key the main container supports,
    except lifecycle hooks and probes

Can be defined in:

- `.Values`.upgradeContainers

---

Defines containers that will run only at the upgrade of a Chart,
before the main container.

Examples:

```yaml
upgradeContainers:
  container-name:
    enabled: true
    imageSelector: image # The name of the image dict to pull repo, tag, pullPolicy
    env:
      key: value
```

---
---

## key: systemContainers

Info:

- Type: `dict`
- Default: `{}`
- Helm Template: ✅|❌
  - Supports almost every key the main container supports,
    except lifecycle hooks and probes

Can be defined in:

- `.Values`.systemContainers

---

Defines containers that will run and exit on each Chart startup,
before the main container and before the initContainers.

Usually used for common things like db-waits or maybe something
that will check files ownership.

Examples:

```yaml
systemContainers:
  container-name:
    enabled: true
    imageSelector: image # The name of the image dict to pull repo, tag, pullPolicy
    env:
      key: value
```

---
---

## key: initContainers

Info:

- Type: `dict`
- Default: `{}`
- Helm Template: ✅|❌
  - Supports almost every key the main container supports,
    except lifecycle hooks and probes

Can be defined in:

- `.Values`.initContainers

---

Defines containers that will run and exit on each Chart startup before the main container.

Examples:

```yaml
initContainers:
  container-name:
    enabled: true
    imageSelector: image # The name of the image dict to pull repo, tag, pullPolicy
    env:
      key: value
```
