# connect-iq-bambu

A Garmin Connect IQ watch app, built in a devcontainer. Target device:
**Venu X1** (`venux1`), Connect IQ SDK **9.2.0**.

## Layout

```
manifest.xml          app id, type, target products, permissions
monkey.jungle         build configuration
source/               Monkey C source (App + View)
resources/            strings, layout, launcher icon
build.sh              compile to bin/connect-iq-bambu.prg
.devcontainer/        devcontainer + post-create (SDK is from a shared feature)
```

## Devcontainer

The container is assembled from a mix of
[official devcontainer features](https://github.com/devcontainers/features)
and [`geoff-coppertop/devcontainer-features`](https://github.com/geoff-coppertop/devcontainer-features):

- `devcontainers/github-cli` — `gh` on `PATH`.
- `geoff-coppertop/shell-baseline` — shell tooling + shared fish/git dotfiles.
- `geoff-coppertop/connect-iq-sdk` (`version: 9.2.0`) — installs the JDK, the
  `connect-iq-sdk-manager` CLI, and the Connect IQ SDK (anonymous download),
  and puts `monkeyc` on `PATH`.
- `geoff-coppertop/claude-code` — Claude Code CLI (and, for VS Code users,
  the Claude Code extension). A named volume `claude-code-state` is mounted
  at `~/.claude` so credentials and session memory survive container rebuilds.

### Podman caveat

`runArgs: ["--userns=keep-id"]` is set so the rootless Podman user namespace
preserves your host UID inside the container and bind-mounted workspace
files stay writable. Docker rejects this flag — collaborators on Docker
need to remove it locally (or use `--userns=host`).

### Garmin credentials are required

Downloading **device files** and **building** require a Garmin account. The SDK
itself downloads anonymously, but the per-device compiler files do not. Provide:

```sh
export GARMIN_USERNAME="you@example.com"
export GARMIN_PASSWORD="..."
```

on the host before opening the container (or set them as Codespaces/repo
secrets). `post-create.sh` uses them to log in and run
`connect-iq-sdk-manager device download --manifest manifest.xml`.

> Note: accounts with two-factor auth may not work with non-interactive
> username/password login. If login fails, run `connect-iq-sdk-manager login`
> interactively inside the container once.

`post-create.sh` also generates a local Connect IQ developer signing key
(`developer_key.der`) — it is git-ignored and never leaves the container.

## Build

```sh
./build.sh            # builds bin/connect-iq-bambu.prg for venux1
./build.sh <device>   # build for another product id listed in manifest.xml
```

or run the **Build (venux1)** task in VS Code (`Ctrl/Cmd+Shift+B`).

## Run

`build.sh` only compiles. To run the app you need the Connect IQ **simulator**
(`connectiq` + `monkeydo`), which is a GUI tool and not available in a headless
container — use it on a desktop SDK install, or sideload the `.prg` to a device.
