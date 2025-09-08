# DevContainers for PairSpaces

Use PairSpaces (https://docs.pairspaces.com) and work together with your team using DevContainers (see https://containers.dev).

## Description

The PairSpaces Devcontainer Feature configures a Devcontainer as a Space where you can work together with your team from the same Devcontainer. Learn more about working together from our [documentation](https://docs.pairspaces.com).

## Usage

In your `.devcontainer.json`:

```json
{
  ...,
  "features": {
    "ghcr.io/pairspaces/devcontainers/pairspaces:X.Y.Z": {
      "token": "[OUTPUT from `pair spaces authorize` HERE]"
    }
  },
  "postAttachCommand": "/opt/pair/pair spaces bootstrap",
  "remoteUser": "root",
  ...
}
```

## Issues

You can open an issue [here](https://github.com/pairspaces/devcontainers/issues) or email us at support at pairspaces dot com.

## Licence

See LICENCE.md
