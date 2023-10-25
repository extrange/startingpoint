# My OS in a container

Custom OS with personalization, based off [Fedora Silverblue], an immutable variant of Fedora. Uses [Universal Blue's `startingpoint`][startingpoint] repository template.

[![build]][build-yml]

The OS image is automatically rebuilt daily, thanks to [Github Actions]. It is then pulled automatically by all my machines using this OS.

## Changes from stock Fedora Silverblue

- `systemd` timers for automatic Flatpak and `rpm-ostree` updates
- removes the default Firefox package (Flatpak Firefox has better [codec support])
- layers [additional packages] e.g. `ffmpeg`, `libheif-tools`, `fzf`, `distrobox`, `vim`, `tmux`



## Getting started

See the [Make Your Own-page in the documentation](https://universal-blue.org/tinker/make-your-own/) for quick setup instructions for setting up your own repository based on this template.

Don't worry, it only requires some basic knowledge about using the terminal and git.

After setup, it is recommended you update this README to describe your custom image.

> **Note**
> Everywhere in this repository, make sure to replace `ublue-os/startingpoint` with the details of your own repository. Unless you used one of the automatic repository setup tools in which case the previous repo identifier should already be your repo's details.

> **Warning**
> To start, you _must_ create a branch called `live` which is exclusively for your customizations. That is the **only** branch the GitHub workflow will deploy to your container registry. Don't make any changes to the original "template" branch. It should remain untouched. By using this branch structure, you ensure a clear separation between your own "published image" branch, your development branches, and the original upstream "template" branch. Periodically sync and fast-forward the upstream "template" branch to the most recent revision. Then, simply rebase your `live` branch onto the updated template to effortlessly incorporate the latest improvements into your own repository, without the need for any messy, manual "merge commits".

## Customization

The easiest way to start customizing is by looking at and modifying `config/recipe.yml`. It's documented using comments and should be pretty easy to understand.

If you want to add custom configuration files, you can just add them in the `/usr/etc/` directory, which is the official OSTree "configuration template" directory and will be applied to `/etc/` on boot. `config/files/usr` is copied into your image's `/usr` by default. If you need to add other directories in the root of your image, that can be done using the `files` module. Writing to `/var/` in the image builds of OSTree-based distros isn't supported and will not work, as that is a local user-managed directory!

For more information about customization, see [the README in the config directory](config/README.md)

Documentation around making custom images exists / should be written in two separate places:

- [The Tinkerer's Guide on the website](https://universal-blue.org/tinker/make-your-own/) for general documentation around making custom images, best practices, tutorials, and so on.
- Inside this repository for documentation specific to the ins and outs of the template (like module documentation), and just some essential guidance on how to make custom images.

## Installation

> **Warning** > [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable) and should not be used in production, try it in a VM for a while!

To rebase an existing Silverblue/Kinoite installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/startingpoint:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/startingpoint:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

This repository builds date tags as well, so if you want to rebase to a particular day's build:

```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/startingpoint:20230403
```

This repository by default also supports signing.

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## ISO

This template includes a simple Github Action to build and release an ISO of your image.

To run the action, simply edit the `boot_menu.yml` by changing all the references to startingpoint to your repository. This should trigger the action automatically.

The Action uses [isogenerator](https://github.com/ublue-os/isogenerator) and works in a similar manner to the official Universal Blue ISO. If you have any issues, you should first check [the documentation page on installation](https://universal-blue.org/installation/). The ISO is a netinstaller and should always pull the latest version of your image.

Note that this release-iso action is not a replacement for a full-blown release automation like [release-please](https://github.com/googleapis/release-please).

## `just`

The [`just`](https://just.systems/) command runner is included in all `ublue-os/main`-derived images.

You need to have a `~/.justfile` with the following contents and `just` aliased to `just --unstable` (default in posix-compatible shells on ublue) to get started with just locally.

```
!include /usr/share/ublue-os/just/main.just
!include /usr/share/ublue-os/just/nvidia.just
!include /usr/share/ublue-os/just/custom.just
```

Then type `just` to list the just recipes available.

The file `/usr/share/ublue-os/just/custom.just` is intended for the custom just commands (recipes) you wish to include in your image. By default, it includes the justfiles from [`ublue-os/bling`](https://github.com/ublue-os/bling), if you wish to disable that, you need to just remove the line that includes bling.just.

See [the just-page in the Universal Blue documentation](https://universal-blue.org/guide/just/) for more information.

[startingpoint]: https://github.com/ublue-os/startingpoint
[build]: https://github.com/extrange/startingpoint/actions/workflows/build.yml/badge.svg
[build-yml]: https://github.com/extrange/startingpoint/actions/workflows/build.yml
[Github Actions]: https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions
[Fedora Silverblue]: https://fedoraproject.org/silverblue/
[`ublue-os/main`]: https://universal-blue.org/images/main/#features
[codec support]: https://docs.fedoraproject.org/en-US/fedora-silverblue/faq/#_how_can_i_play_more_videos_in_firefox_like_youtube
[additional packages]: https://github.com/ublue-os/main/blob/main/packages.json