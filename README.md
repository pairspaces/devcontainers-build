# DevContainers for PairSpaces

Use PairSpaces (https://docs.pairspaces.com) and work together with your team using DevContainers (see https://containers.dev).

## Description

The PairSpaces Devcontainer Feature configures a Devcontainer as a Space where you can work together with your team from the same Devcontainer. Learn more about working together from our [documentation](https://docs.pairspaces.com).

## Usage

Create a Space Key locally (requires an account):

```bash
pair keys create
```

Then add the key to GitHub Codespaces as a secret named `PS_SPACE_KEY`.

Using the GitHub CLI:

```bash
gh secret set PS_SPACE_KEY --app codespaces --repos OWNER/REPO
```

Using the GitHub UI:

1. Go to GitHub Settings.
2. Open Codespaces.
3. Open Codespaces secrets.
4. Create a secret named `PS_SPACE_KEY`.
5. Paste the Space Key and grant access to the repository.

In your `.devcontainer.json`:

```json
{
  ...,
  "features": {
    "ghcr.io/pairspaces/devcontainers/pairspaces:X.Y.Z": {}
  },
  "postAttachCommand": "/opt/pair/pair spaces connect",
  "remoteUser": "root",
  ...
}
```

Do not commit `PS_SPACE_KEY` or a Space Key value to your repository. For non-Codespaces DevContainers, provide `PS_SPACE_KEY` through your runtime's secret or environment variable mechanism.

## Issues

You can open an issue [here](https://github.com/pairspaces/devcontainers/issues) or email us at support at pairspaces dot com.

## Licence

See LICENCE.md
