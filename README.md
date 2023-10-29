# My customized, immutable OS in a container

[![build]][build-yml]

 Also see my custom [distrobox].

Based off [Fedora Silverblue], an immutable variant of Fedora. Uses [Universal Blue's `startingpoint`][startingpoint] repository template.

Configure your OS in configuration files like this:

```yaml
# Install flatpaks
description: Additional applications I use
packages:
  - Calibre: com.calibre_ebook.calibre
  - Jellyfin: com.github.iwalton3.jellyfin-media-player
  - LibreOffice: org.libreoffice.LibreOffice
  - Moonlight: com.moonlight_stream.Moonlight
  - OBS Studio: com.obsproject.Studio
  - Obsidian: md.obsidian.Obsidian
  - Scrcpy: in.srev.guiscrcpy
  - Telegram: org.telegram.desktop
  - Ungoogled Chromium: com.github.Eloston.UngoogledChromium
  - VLC: org.videolan.VLC
  - Zoom: flathub us.zoom.Zoom
```

```yaml
# Run arbitrary scripts
- type: script
  scripts:
    - flatpak-updates.sh
    - install-gext.sh
    - rpm-ostree-update.sh
    - signing.sh
    - starship.sh
    - vim-default-editor.sh
```

```dockerfile
# Run Dockerfile commands

COPY build.sh /tmp/build.sh
COPY config /tmp/config/
RUN rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```
Automatically rebuilt daily, thanks to [Github Actions].

Pulled regularly to all my machines (via `systemd` timers).

Inspired by this [post].

## Features

- Automatic flatpak/OS updates (when on AC power and unmetered connection)
- Additional flatpaks: Jellyfin, Moonlight, Telegram (see full [list][yafti])
- Additional packages: `ffmpeg`, `libheif-tools`, `distrobox`, `tailscale`, `vim` (see full [list][packages])
- Replace system Firefox with flatpak version (Flatpak Firefox has better [codec support])
- Custom GNOME settings ([list][yafti])
- GNOME extensions: GSConnect, Clipboard Indicator ([list][yafti])
- [Starship.rs] shell prompt

## Installation

> [!IMPORTANT]
> Before installing anything, you will need to back up your existing configuration:
>
> - `~/.ssh` keys
> - Firefox profile
> - `nm-cli` connections
> - `/etc/fstab`
> - Syncthing `.config`

You will need to begin with an existing [Fedora Silverblue] installation.

Next, rebase an installation to this OS:

```bash
# Remove all layered packages to prevent any conflicts
rpm-ostree reset

# Rebase to the unsigned image to install container signing policies.
# This updates /etc/containers/policy.json (see signing.sh)
rpm-ostree rebase ostree-unverified-registry:ghcr.io/extrange/startingpoint

# Reboot to complete the rebase:
reboot

# Then rebase to the signed image, like so:
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/extrange/startingpoint

# Reboot again to complete the installation
reboot
```

**Post install setup**

You will need to configure:

- `git` credentials
- `syncthing` is installed but not enable by default. To enable:

  - `systemctl --user enable syncthing.service`

Finally, don't forget to copy over the configuration files you backed up previously.

## Notes

The `template` branch tracks that of the upstream [`startingpoint`][startingpoint] repo. The `live` branch is used for actual deployment.

The `template` branch is periodically synced and the `live` branch is rebased on it periodically to incorporate the latest improvements without the need for any messy, manual "merge commits".

This repository builds date tags as well, so if you want to rebase to a particular day's build:

```bash
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/extrange/startingpoint:20230403
```

This repository by default also supports signing.

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## ISO

This template includes a simple Github Action to build and release an ISO of your image.

To run the action, simply edit the `boot_menu.yml` by changing all the references to startingpoint to your repository. This should trigger the action automatically.

The Action uses [isogenerator](https://github.com/ublue-os/isogenerator) and works in a similar manner to the official Universal Blue ISO. If you have any issues, you should first check [the documentation page on installation](https://universal-blue.org/installation/). The ISO is a netinstaller and should always pull the latest version of your image.

## Technical

- `/usr` is readonly at runtime. `/etc` is meant for mutable machine-local files, and `/var` holds all other state (and is also preserved across updates). [More info][filesystem-layout]
- On the booted deployment, [`/sysroot` is a bind mount to the physical `/` root directory][sysroot]
- Packages layered with `rpm-ostree install` are automatically kept [up to date], and are kept after a rebase.
- For more information about the URL formats (e.g. `ostree-unverified-registry:<oci image>`), see [here][url-format]
- On an upgrade of a deployment, a [3-way merge] is performed between the currently booted deployment's `/etc`, the default configuration (as in `/usr/etc`), and the new deployment's `/usr/etc`.
- During container builds (e.g. in a `Containerfile`), it's good practice to do [`ostree container commit`] after each `RUN` instruction.
- `/etc/containers/policy.json` sets the system policy for [container signature verification].

[startingpoint]: https://github.com/ublue-os/startingpoint
[build]: https://github.com/extrange/startingpoint/actions/workflows/build.yml/badge.svg
[build-yml]: https://github.com/extrange/startingpoint/actions/workflows/build.yml
[Github Actions]: https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions
[Fedora Silverblue]: https://fedoraproject.org/silverblue/
[codec support]: https://docs.fedoraproject.org/en-US/fedora-silverblue/faq/#_how_can_i_play_more_videos_in_firefox_like_youtube
[post]: https://www.ypsidanger.com/building-your-own-fedora-silverblue-image/
[yafti]: config/files/usr/share/ublue-os/firstboot/yafti.yml
[packages]: config/recipe.yml
[Starship.rs]: https://starship.rs/
[url-format]: https://coreos.github.io/rpm-ostree/container/#url-format-for-ostree-native-containers
[filesystem-layout]: https://coreos.github.io/rpm-ostree/container/#filesystem-layout-model
[sysroot]: https://ostreedev.github.io/ostree/adapting-existing/#system-layout
[up to date]: https://docs.fedoraproject.org/en-US/iot/update-applications/#_updating_layered_packages
[3-way merge]: https://ostreedev.github.io/ostree/atomic-upgrades/#assembling-a-new-deployment-directory
[`ostree container commit`]: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
[container signature verification]: https://github.com/containers/image/blob/main/docs/containers-policy.json.5.md#policy-requirements
[distrobox]: https://github.com/extrange/my-distrobox