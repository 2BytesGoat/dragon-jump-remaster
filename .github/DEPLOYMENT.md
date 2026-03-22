# Deployment Guide

This project builds and publishes to **itch.io** and **Steam** via GitHub Actions.

## Pipeline Overview

- **Build job**: Compiles the game for Web and Windows, uploads artifacts
- **Publish job**: Pushes builds to itch.io, then to Steam (if configured)

Triggers: push to `v*` tags, or manual `workflow_dispatch`.

## itch.io

Required secrets:

- `BUTLER_API_KEY` – from [itch.io API keys](https://itch.io/user/settings/api-keys)
- `EXPORT_NAME` – name of the Windows `.exe` (e.g. `DragonJump`)

## Steam

### Prerequisites

1. Partner account at [Steamworks](https://partner.steamgames.com/)
2. App created with depots configured
3. **Build account** with only "Edit App Metadata" and "Publish App Changes To Steam"
4. MFA enabled on the build account

### GitHub Secrets

Add these in **Settings → Secrets and variables → Actions**:

| Secret           | Description                                                       |
|------------------|-------------------------------------------------------------------|
| `STEAM_APP_ID`   | App ID from your [Steamworks dashboard](https://partner.steamgames.com/dashboard) |
| `STEAM_USERNAME` | Username of the Steam build account                               |
| `STEAM_CONFIG_VDF` | Base64-encoded `config/config.vdf` (see below)                 |

### Steam auth (`STEAM_CONFIG_VDF`)

1. Install [steamcmd](https://partner.steamgames.com/doc/sdk/uploading#1) locally
2. Run `steamcmd +login <build_account> +quit` and complete MFA
3. Encode the config:
   - **Linux/macOS**: `cat ~/.steam/steam/config/config.vdf | base64 -w0`
   - **Windows**: `certutil -encode -f "C:\Program Files (x86)\Steam\config\config.vdf" tmp.b64`
4. Put the base64 string into the `STEAM_CONFIG_VDF` secret

If Steam asks for MFA again later, regenerate this secret.

### Depot setup

| Depot       | ID               | Content                                      |
|------------|------------------|----------------------------------------------|
| Windows    | `STEAM_APP_ID+1` | Windows build                                |
| MacOS      | `STEAM_APP_ID+2` | Placeholder (no longer supported)            |
| Linux      | `STEAM_APP_ID+3` | Linux x86_64 build                           |

Ensure depots 1–3 exist in Steamworks. The `prerelease` branch is used; move the build to `default` when ready to go live.

### Skipping Steam

- **Manual run**: uncheck "Publish to Steam" in the workflow dispatch form
- **Tag pushes**: Steam always runs if the secrets exist; to skip Steam, remove or omit the Steam secrets
