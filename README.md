# OLP NixOS Configuration

NixOS configurations for UTC Sheffield OLP's MakerLab computers, exam timers, and browser displays. The repository defines installed software, desktop settings, machine profiles, installation media, and a client for distributing configuration updates.

The flake uses the `nixos-25.11` branch of Nixpkgs. Exact dependency revisions are recorded in `flake.lock`.

## Machine profiles

Use these names when the installer asks for a configuration or when running `nixos-rebuild`:

| Profile | Architecture | Purpose |
| --- | --- | --- |
| `makerlab` | x86_64 Linux | KDE Plasma 6 desktop with Firefox, Chromium, VS Code, Python, OpenSCAD, Bambu Studio, Node.js 24, and pnpm. Uses a UK keyboard layout. |
| `makerlab-us` | x86_64 Linux | MakerLab desktop with a US keyboard layout. |
| `exam-timer` | x86_64 Linux | Automatically opens the UTC Exam Timer in Chromium app mode and periodically mirrors connected displays. |
| `kiosk` | x86_64 Linux | Base configuration with boot specialisations for different browser displays. |
| `iso` | x86_64 Linux | Installation ISO with networking prompts and the installation launcher. |

The PC profiles use UEFI/systemd-boot and filesystems identified by the labels `boot`, `nixos`, and `swap`.

## Repository layout

| Path | Contents |
| --- | --- |
| `flake.nix` | Machine configurations, package outputs, and Hydra build jobs. |
| `flake.lock` | Pinned input revisions. |
| `default.nix` | Discovers custom package definitions and exports flat and nested package sets. |
| `machines/` | Desktop, kiosk, exam timer, and installer profiles. |
| `hardware/generic.nix` | Shared PC boot, filesystem, and hardware settings. |
| `programs/` | Reusable application and service configuration. |
| `programs/packages/` | Custom Nix packages, including additional Python libraries. |
| `setup.sh` | Downloads and starts the installation script. |
| `setuppt2.sh` | Prompts for installation settings, prepares the disk, and installs NixOS. |
| `update-tool/` | Go update client/server and their NixOS service module. |
| `.github/workflows/` | Flake checks and installer ISO builds. |

## Installing a PC

**The default installer erases and repartitions the selected drive. Back up anything needed and check the device name before submitting the drive prompt. There is no additional erase confirmation.**

1. Boot the repository's [installation ISO](https://github.com/UTCSheffield/olp-nixos-config/releases), or a [minimal NixOS installer](https://nixos.org/download/), in UEFI mode.
2. Connect to the internet. The custom ISO offers a Wi-Fi setup prompt and starts the installer on its first console.
3. If using a standard minimal ISO, download and run the launcher:

   ```bash
   curl -fL https://raw.githubusercontent.com/UTCSheffield/olp-nixos-config/master/setup.sh -o setup.sh
   sudo bash setup.sh
   ```

4. Enter the hostname, root password, profile name, Git branch, and target drive. The defaults are `makerlab` and `master`.
5. After a successful installation, reboot and remove the installation media.

The installer creates a GPT partition table with an approximately 2 GiB FAT32 EFI partition, an ext4 root partition, and 8 GiB of swap. It clones the selected branch into `/etc/nixos`, writes `system.conf`, installs the selected profile, and sets the root password. It also attempts to copy the active NetworkManager Wi-Fi profile to the installed system.

The launcher always downloads `setuppt2.sh` from `master`; the branch prompt selects the configuration branch installed on the target.

### Installing with existing partitions

The installation script accepts `--no-disk-format`:

```bash
sudo bash setup.sh --no-disk-format
```

This skips partitioning, formatting, mounting, and enabling swap. Prepare and mount the target root at `/mnt` and its EFI partition at `/mnt/boot` first. The selected profile must match the existing filesystem layout. This option still replaces `/mnt/etc/nixos` and performs an installation; it is not the normal update procedure.

## Per-machine settings

The installer creates `/etc/nixos/system.conf`:

```ini
hostname = "olp-makerlab-01"
config = "makerlab"
```

The update client reads this file to set the hostname and choose the flake profile to rebuild. It synchronises the hostname on startup and every minute while running.

`system.conf` is local machine data. It is not imported by the flake, so manual rebuild commands must explicitly select the profile using `#makerlab`, `#kiosk`, or another output name. Keep the file's `config` value consistent with the profile installed on the machine.

## Updating a machine

To fetch committed configuration changes and apply a profile manually:

```bash
cd /etc/nixos
sudo git pull --ff-only
sudo nixos-rebuild switch --flake .#makerlab
```

Replace `makerlab` with the machine's profile. Review any local changes before pulling.

### Automatic updates

The `makerlab`, `makerlab-us`, `exam-timer`, and `kiosk` profiles enable `update-tool`. It reads the desired commit from `https://nixos-updates.archiesbytes.xyz/poll`, compares it with the local checkout, and runs `git pull` followed by `nixos-rebuild switch` when they differ.

The client currently only updates checkouts on `master`. A machine installed from another branch requires manual updates.

Check the service and its logs with:

```bash
systemctl status update-tool
journalctl -u update-tool -b
```

To pause updates during local work:

```bash
sudo systemctl stop update-tool
```

Start it again with `sudo systemctl start update-tool`. Stopping it is temporary; it can start again after a reboot or service activation during a rebuild.

### Switching profiles

Pause the update client, edit `/etc/nixos/system.conf` to select the new profile, then rebuild it explicitly:

```bash
sudo systemctl stop update-tool
sudo nano /etc/nixos/system.conf
sudo nixos-rebuild switch --flake /etc/nixos#kiosk
```

Reboot after changing desktop/display profiles. If the new profile includes the update client and it remains stopped, start it again.

## Kiosk displays

The `kiosk` profile defines the following boot specialisations:

| Specialisation | Display |
| --- | --- |
| `sprig-gallery` | Sprig Arcade gallery. |
| `exam-timer` | UTC Exam Timer. |
| `adhoc-exam-timer` | Ad hoc exam timer. |
| `healthcareers-nhs` | NHS Find Your Career. |
| `computing-open-evening` | Computing open evening page. |

After installing `kiosk`, select the required specialisation from the boot menu. The base configuration leaves `kiosk.url` empty; a specialisation sets the URL and enables the graphical session.

The browser session uses Chromium app mode, Openbox, automatic login, disabled screen blanking, and periodic display mirroring. The kiosk profile also starts a network configuration interface on TTY2, accessible using `Ctrl` + `Alt` + `F2`.

To add another display, add an entry inside `specialisation` in `machines/kiosk.nix`:

```nix
my-display.configuration = {
  kiosk.url = "https://example.org/display";
};
```

Rebuild the `kiosk` profile and reboot to select the new entry. Boot specialisations such as `sprig-gallery` are not separate top-level flake profiles.

## Making configuration changes

- Change a machine's software and settings in its file under `machines/`.
- Put reusable application settings in `programs/` and import them into the relevant machine profiles.
- Add shared Python libraries in `programs/python-env.nix`. Libraries packaged locally are defined under `programs/packages/python313Packages/`.
- Change VS Code extensions in `programs/vscode.nix`.
- Change Firefox policies in `programs/firefox.nix`.

Keep machine passwords and other secrets out of new commits. MakerLab's account password is defined by a hash in its machine profile; the installer's password prompt sets the root password separately.

### Updating dependencies

Pulling this repository uses the revisions already recorded in `flake.lock`. To update flake inputs deliberately:

```bash
nix flake update
```

Review and test the lock-file changes before committing them. Updating the lock file follows the input branches configured in `flake.nix`; changing the NixOS release requires changing the Nixpkgs input there. Do not change `system.stateVersion` merely to update packages.

## Building and checking

Run these commands from the repository root on a system with Nix and flakes enabled.

Check the flake:

```bash
nix flake check
```

Build a PC profile without activating it:

```bash
nix build .#nixosConfigurations.makerlab.config.system.build.toplevel --print-build-logs
```

Build the installer ISO:

```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage --print-build-logs
```

The ISO is placed under `result/iso/`.

GitHub Actions runs `nix flake check` for pushes to `master` and pull requests. A separate workflow builds installation ISOs for its configured path filters or manual dispatch, and publishes a release for qualifying pushes to `master`.

## Troubleshooting and recovery

| Problem | Checks |
| --- | --- |
| Automatic updates fail | Check `journalctl -u update-tool -b`, network access, the checkout branch, local Git changes, and `system.conf`. |
| No network connection | Run `nmcli device status` or `sudo nmtui`. On kiosk machines, try TTY2. |
| Kiosk has no browser | Check that a display specialisation was selected, then inspect `journalctl -u greetd -b` and `/tmp/xinit-debug.log`. |
| Displays are not mirrored | Check `systemctl status mirror.timer` and `journalctl -u mirror -b`. |
| A new configuration fails | Select a previous generation in the systemd-boot menu. For an immediate manual rollback, use `sudo nixos-rebuild switch --rollback`. |

A rollback changes the active system generation; it does not revert the Git checkout or `system.conf`. Pause automatic updates while diagnosing a bad revision so it is not reapplied.
