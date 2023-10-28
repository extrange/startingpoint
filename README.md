# My OS in a container

Custom OS with personalization, based off [Fedora Silverblue], an immutable variant of Fedora. Uses [Universal Blue's `startingpoint`][startingpoint] repository template. Written in OCI

Inspired by this [post].

[![build]][build-yml]

The OS image is automatically rebuilt daily, thanks to [Github Actions]. It is then pulled automatically by all my machines using this OS.

**Changes from stock Fedora Silverblue**

- `systemd` timers for automatic Flatpak and `rpm-ostree` updates
- removes the default Firefox package (Flatpak Firefox has better [codec support])
- layers [additional packages] e.g. `ffmpeg`, `libheif-tools`, `fzf`, `distrobox`, `vim`, `tmux`

The main files which are not changed from upstream `startingpoint` are `build.sh`.

## Installation

> [!IMPORTANT]
> Before installing anything, you will need to back up your existing configuration:
> 
> - `~/.ssh` keys
> - Firefox profile
> - `nm-cli` connections
> - `/etc/fstab`
> - Syncthing `.config`

**Install**

To rebase an existing Silverblue/Kinoite installation to the latest build:

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

Note that this release-iso action is not a replacement for a full-blown release automation like [release-please](https://github.com/googleapis/release-please).

## Technical

- Only /var is preserved across updates. /sysroot is a bind mount to the real root directory.
- Packages installed with rpm-ostree are automatically kept up to date
- layered packages are kept after a rebase

policy JSON, container signing, what ostree container commit does, ostree-unverified-registry , filesystem layout model - https://coreos.github.io/rpm-ostree/container/

https://ostreedev.github.io/ostree/adapting-existing/, https://ostreedev.github.io/ostree/atomic-upgrades/ - /usr/etc stuff, 3 way merge

## References

- Universal Blue [documentation](https://universal-blue.org/tinker/make-your-own/)

[startingpoint]: https://github.com/ublue-os/startingpoint
[build]: https://github.com/extrange/startingpoint/actions/workflows/build.yml/badge.svg
[build-yml]: https://github.com/extrange/startingpoint/actions/workflows/build.yml
[Github Actions]: https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions
[Fedora Silverblue]: https://fedoraproject.org/silverblue/
[codec support]: https://docs.fedoraproject.org/en-US/fedora-silverblue/faq/#_how_can_i_play_more_videos_in_firefox_like_youtube
[additional packages]: https://github.com/ublue-os/main/blob/main/packages.json
[post]: https://www.ypsidanger.com/building-your-own-fedora-silverblue-image/
