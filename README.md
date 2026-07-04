# `~/.dotfiles`

## macOS

Install Apple's Command Line Tools, which are prerequisites for Git and
Homebrew.

  ```sh
  xcode-select --install
  ```

## On Linux

📦 Update your machine

  ```sh
  sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y &&
  sudo apt autoclean -y && apt install build-essential
  ```

**Install and set up zsh as default.**

  ```sh
  sudo apt install zsh && zsh --version
  # Expected result: zsh 5.9 or more recent

  # Make it default shell
  chsh -s $(which zsh)
  ```
  
**Restart you machine to use the new default shell. To test if it worked:**

  ```sh
  echo $SHELL
  # Expected result: /bin/zsh or similar.
  ```

1. **Clone repo into a new hidden directory**.

  ```sh
  # Use SSH (if set up)...
  git clone git@github.com:skekcoon/dotfiles.git ~/.dotfiles

  # ...or use HTTPS and switches remote later
  git clone https://github.com/skekcoon/dotfiles.git ~/.dotfiles
  ```

1. **Install Homebrew followed by the software listed in the Brewfile…**

  ```sh
  # Install Homebrew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Then pass in the Brewfile location...
  brew bundle --file ~/.dotfiles/Brewfile
  ```

**Stow everything in place.**

  ```sh
  # Make sure to be in ~/.dotfiles to run:
  stow .
  ```

## Software Configurations

### Thunderbird

#### **Step 1**: Check IMAP folder subscription

1. In Thunderbird, right-click your **@me.com account** in the left sidebar.
2. Select **Subscribe…**.
3. Make sure the following iCloud folders are subscribed:

- **Sent Messages**
- **Deleted Messages**
- **Drafts**
- **Junk**

1. Click **OK**.

#### **Step 2**: Map the special folders

1. Right-click the **account name** in the sidebar → choose **Settings**.
2. Go to **Copies & Folders**.

   - Under **Sent Messages**, select “Place a copy in → Other → Sent
     Messages on \<your @me.com account>.”
   - Under **Drafts and Templates**, select the correct **Drafts**
     folder on the @me.com account.
   - For **Archives**, point to the iCloud **Archive** folder (if you
     use it).

3. Go to **Server Settings** (still in Account Settings).

   - Under **When I delete a message**, select **Move it to this folder
     → Deleted Messages on \<your @me.com account>**.

## TODO List

- Learn how tu use `defaults` to record and restore System Preferences and other macOS configurations.
- Organize these growing steps into multiple scripts.
- Automate symlinks and run script files with a boostrapping tool like [dotbot](https://github.com/anishathalye/dotbot) or [GNU Stow](https://www.gnu.org/software/stow/).
- M@ake a checklist of steps to decommission your computer before wiping your hard drive.
- Create a [bootable USB installer for macOS](https://support.apple.com/en-us/101578).
- Integrate other cloud services into your Dotfiles process (Dropbox, Google Drive, etc.).
- Find inspiration and examples in other Dotfiles repositories at [dotfiles.github.io](https://dotfiles.github.io/).

---

title: "Preface"
description: "Documentation"
date-modified: 2026-01-04
---

## Introduction

## What is Nix

Nix is a purely functional package manager. This means that it treats
packages like values in purely functional programming languages such as
Haskell — they are built by functions that don’t have side-effects, and
they never change

### Nix

### Nixpkgs

### NixOS

------

# [How Nix Works](https://nixos.org/guides/how-nix-works/)

- > after they have been built. Nix stores packages in the Nix store,
usually the directory `/nix/store`, where each package has its own unique
subdirectory such as:

```sh
/nix/store/b6gvzjyb2pg0kjfwrjmg1vfhh54ad73z-firefox-33.1/
```

Where `b6gvzjyb2pg0…` is a unique identifier for the package that captures all
its dependencies (it’s a cryptographic hash of the package’s build dependency
graph). This enables many powerful features.

## Manuels

1. [Nix](https://nix.dev/manual/nix/2.28/)
2. [Nixpkgs](https://nixos.org/manual/nixpkgs/stable/)
3. [NixOS](https://nixos.org/manual/nixos/stable/)

## [Documentation](https://nix.dev/)

----

# Home Lab

## Home Lab: NixOS + hyprland

- <https://www.youtube.com/watch?v=maw2hptpErI>
- <https://nixos.org/guides/how-nix-works/>
- OMARCHY: <https://github.com/basecamp/omarchy>
- <https://www.youtube.com/watch?v=61wGzIv12Ds>
- <https://christitus.com/nixos-explained/>
- Essayer NixOS without "unfree software"

## 🧪 Building a Home Lab with VirtualBox

For a long time, building a home lab meant investing in physical hardware—servers,
routers, switches, and more. But today, most modern computers are powerful enough
to run several virtual machines (VMs) simultaneously using a **hypervisor**.

A **hypervisor** is software that allows you to create and manage virtual
machines. It lets your host computer (e.g., a desktop or laptop) allocate memory,
CPU, and other resources to virtual environments that run independently of your
host operating system.

This isolation is especially useful for security research, development testing,
or connecting to external networks (e.g., client environments) safely. While VM
breakout vulnerabilities exist, this model still provides a solid layer of
protection.

## 🧰 Installing VirtualBox

### Prerequisites

In order for VirtualBox to run other operating system in virtual machine
alongside a linux host, it requires drivers modules:

- `vboxdrv` – core driver module
- `vboxnetflt` and `vboxnetadp` – for virtual networking

Before these modules can be built, ensure that `gcc`, `make`, and the correct
kernel headers are installed.

#### Check if `gcc` and `make` are available

```sh
which gcc make
```

Expected output:

```sh
/usr/bin/gcc
/usr/bin/make
```

#### Install kernel headers (if not already present)

```bash
sudo apt install linux-headers-$(uname -r)
```

#### UEFI Secure Boot and unsigned kernel modules

If your system uses **UEFI Secure Boot**, unsigned kernel modules won't be
loaded. You'll need to **manually sign** the VirtualBox kernel modules.
This is required because Secure Boot only allows signed kernel modules
to load, and VirtualBox modules are unsigned by default.

1. **🔍 Check Secure Boot Status.**

  ```sh
  sudo mokutil --sb-state
  ```

If Secure Boot is enabled, you’ll need to generate and enroll a Machine Owner
Key (MOK):

1. **🧾 Create and import a signing key.**

  ```sh
  sudo mkdir -p /var/lib/shim-signed/mok

  sudo openssl req -new -x509 -newkey rsa:2048 -nodes \
      -outform DER \
      -keyout /var/lib/shim-signed/mok/MOK.priv \
      -out /var/lib/shim-signed/mok/MOK.der \
      -subj "/CN=VirtualBox MOK/" \
      -addext "extendedKeyUsage=codeSigning"

  sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
  ```

Reboot your system. During boot, the MOK manager will prompt you to enroll the
key. Once the modules are signed and loaded, you’re ready to install VirtualBox

::: {.callout-tip}
💡 Run `lsmod | grep vbox` to verify that VirtualBox modules are loaded.
:::

### Installing

To install VirtualBox and its extension pack on a Debian-based Linux system:

```bash
sudo apt install virtualbox virtualbox-ext-pack
```

::: {.callout-tip}
💡 The extension pack provides support for USB devices, RDP, and more.
:::

## 🐉 Penetration Testing VM

### Linux: Kali

<https://www.kali.org/docs/virtualization/install-virtualbox-guest-vm/>

Follow the official Parrot documentation for importing the image into VirtualBox:

🔗 [Install Parrot OS on VirtualBox](https://www.parrotsec.org/docs/virtualization/install-parrot-on-virtualbox)
- Encrypt Disk
- virtualbox encryption
<https://academy.hackthebox.com/module/87/section/882>

- Take snapshot
use dotfile to install basic tools such as bitwarden + ghossty + oh my zsh + neovim

### Windows

## Freebox Server as [VPS](../../wiki/vps.qmd)

CPU ; <https://www.marvell.com/content/dam/marvell/en/public-collateral/embedded-processors/marvell-embedded-processors-armada-7040-product-brief-2017-12.pdf>
Crucial RAM CT16G4SFD824A 16Go DDR4 2400MHz CL17 Mémoire d’ordinateur Portable
4 x Seagate BarraCuda, 2 To, Disque dur interne HDD – 2,5" SATA 6 Gbit/s 5 400 tr/min, 128 Mo de mémoire cache, pour PC portable (ST2000LM015)

- [Setting up netbird](https://academy.hackthebox.com/module/87/section/3668)
- [VPS Hardening](https://academy.hackthebox.com/module/87/section/906)

## Terminal

### Ghostty

### starship
<https://starship.rs/>

### TUI

- `lf` <https://github.com/gokcehan/lf>
- `lazygit` <https://github.com/jesseduffield/lazygit>

#### Neovim

text editor

## Shell

- [x] Zsh
  - [x] Ohmyzsh
    - [x] <https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md>
    - [x] <https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md>
- [x] [fzf](https://github.com/junegunn/fzf)
- [x] [eza](https://github.com/eza-community/eza?tab=readme-ov-file)
- [x] [batcat](https://github.com/sharkdp/bat)
- [x] [btop](https://github.com/aristocratos/btop)

grep ?
wc ?

## Network

### [VPN](./vpn.qmd)

- [x] [openvpn](./Cheatsheets/openvpn.qmd)
- [ ] [Proton VPN](https://protonvpn.com/support/linux-vpn-setup)

## Utilities

### Password Manager

Bitwardan or proton

[wordlist](./Cheatsheets/seclists.qmd): <https://github.com/danielmiessler/SecLists>

### Backup

- [ ] [Pika Backup](https://apps.gnome.org/PikaBackup/)

### Notes taking

- [x] ~vim~ [neovim](https://formulae.brew.sh/formula/neovim#default)
- [ ] [Joplin](https://joplinapp.org/help/install/)

### Windows Manager
<https://github.com/hyprwm/Hyprland?tab=readme-ov-file>

### Webapp
<https://github.com/basecamp/omarchy/blob/master/bin/omarchy-webapp-install>

### AI

- [ ] [Ollama](https://ollama.com/) / LM Studio

## Container

- [ ] [Docker]

## Sandboxing

- Firejail / KASM

## HTTP Utilities

<https://academy.hackthebox.com/module/87/section/3682>

- [curlie](https://rs.github.io/curlie/)
- [Posting.sh](https://posting.sh/)
- [httpie](https://httpie.io/)

## Homelab

### [Virtual Machine](./vm.qmd)

- [ ] virtualbox `sudo apt install virtualbox virtualbox-ext-pack -y`

- asciinema <https://asciinema.org/>

## Tools.list

- smbclient
- [ ] ghostty
- [ ] bitwarden
- [x] [netcat](https://formulae.brew.sh/formula/netcat#default)
- [x] [nmap](https://formulae.brew.sh/formula/nmap#default)
wireshark
tcpdump
hashcat
ffuf
gobuster
hydra
zaproxy
proxychains
sqlmap
radare2
metasploit-framework
python2.7
python3
spiderfoot
theharvester
remmina
xfreerdp
rdesktop
crackmapexec
exiftool
curl
seclists
testssl.sh
- [x] ~vim~ [neovim](https://formulae.brew.sh/formula/neovim#default)
- [x] [openvpn](https://formulae.brew.sh/formula/openvpn#default)
- [responder](https://github.com/lgandx/Responder)
- [John The Ripper](https://www.openwall.com/john/)

- [ ] [Local LLM](https://www.freecodecamp.org/news/local-ai-development-with-ollama-course/)
- [ ] setting up VM with:
    1. [Linux](https://academy.hackthebox.com/module/87/section/882)
    2. [Windows](https://academy.hackthebox.com/module/87/section/883)
- [ ] [Working with SSH key passphrases](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases)
- [ ] README du dotfile
  1. create an ssh key
  2. clone the repo with ssh
  3. install homebrew + `brew analytics off` + follow additional step (execpt PATH and install gcc) + brewfile
  4. stow .
- [ ] shell script pour créer automatiquement la structure d’un répertoire, [[🗃️ directory.tree]] selon un fichier txt.
- [ ] Créer deux repo distincts pour :
 	- [ ] 1. [[🧰 tool.list#Host machine]]
 	- [ ] 2. [[🧰 tool.list#linux pentest virtual-machine]]
- [ ] nextcloud
- [ ] discord
- [ ] web: firefox
- [ ] mail: thunderbird
- [ ] password: bitwarden ou proton pass
- [ ] btop
- [ ] theme: full integration of
- [ ] keybindings : super
  - [ ] super + b = browser
  - [ ] super + enter = terminal

### TUI

- [ ] lf
- [ ] lazygit
- [ ] fastfetch

### Note

- [ ] voir obsidian ou logseq
- [ ] chronologie des posts sur linkedIn dans une blocnote

## TODO List

- Learn how tu use `defaults` to record and restore System Preferences and other macOS configurations.
- Organize these growing steps into multiple scripts.
- Automate symlinks and run script files with a boostrapping tool like [dotbot](https://github.com/anishathalye/dotbot) or [GNU Stow](https://www.gnu.org/software/stow/).
- Make a checklist of steps to decommission your computer before wiping your hard drive.
- Integrate other cloud services into your Dotfiles process (Dropbox, Google Drive, etc.).
- Find inspiration and examples in other Dotfiles repositories at [dotfiles.github.io](https://dotfiles.github.io/).

---

::: {.callout-note}

## Changelog

- **2026-01-04**: bla bla
:::

---

# [LazyVim](https://www.lazyvim.org/)

## File Structure

```bash
~/.config/nvim/
├── init.lua
├── lua
│   ├── config
│   │   ├── autocmds.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua
│   │   └── options.lua
│   └── plugins
│       ├── spec1.lua
│       ├── **
│       └── spec2.lua
└── init.lua
└── lazy-lock.json
```

- `~/.config/nvim/init.lua`: this file **runs first**, bootstraps
  `lazy.nvim` and loads your plugin specs.

### `lua/`

Where all lua modules lives. Neovim automatically search this directory
when you call `require()`.

## Keybindings

| Keybindings    | Actions |
|----------------|---------|
| `shift` + `h`      | Switch between buffer |
| `ctrl` + `h`       | jump from explorer to main buffer |

---

title: "Installing NixOS on a Virtual Machine"
---

<https://nixos.org/manual/nixos/stable/#sec-installing-virtualbox-guest>

Installing in a VirtualBox guest

Installing NixOS into a VirtualBox guest is convenient for users who want to try NixOS without installing it on bare metal. If you want to set up a VirtualBox guest, follow these instructions:

    Add a New Machine in VirtualBox with OS Type “Linux / Other Linux”

    Base Memory Size: 768 MB or higher.

    New Hard Disk of 10 GB or higher.

    Mount the CD-ROM with the NixOS ISO (by clicking on CD/DVD-ROM)

    Click on Settings / System / Processor and enable PAE/NX

    Click on Settings / System / Acceleration and enable “VT-x/AMD-V” acceleration

    Click on Settings / Display / Screen and select VMSVGA as Graphics Controller

    Save the settings, start the virtual machine, and continue installation like normal

There are a few modifications you should make in configuration.nix. Enable booting:

{ boot.loader.grub.device = "/dev/sda"; }

Also remove the fsck that runs at startup. It will always fail to run, stopping your boot until you press *.

{ boot.initrd.checkJournalingFS = false; }

Shared folders can be given a name and a path in the host system in the VirtualBox settings (Machine / Settings / Shared Folders, then click on the “Add” icon). Add the following to the /etc/nixos/configuration.nix to auto-mount them. If you do not add "nofail", the system will not boot properly.

{ config, pkgs, ... }:
{
  fileSystems."/virtualboxshare" = {
    fsType = "vboxsf";
    device = "nameofthesharedfolder";
    options = [
      "rw"
      "nofail"
    ];
  };
}

The folder will be available directly under the root directory.

--

= <https://nixos.org/manual/nixos/stable/#sec-installation-manual>

Manual Installation

NixOS can be installed on BIOS or UEFI systems. The procedure for a UEFI installation is broadly the same as for a BIOS installation. The differences are mentioned in the following steps.

The NixOS manual is available by running nixos-help in the command line or from the application menu in the desktop environment.

To have access to the command line on the graphical images, open Terminal (GNOME) or Konsole (Plasma) from the application menu.

You are logged-in automatically as nixos. The nixos user account has an empty password so you can use sudo without a password:

sudo -i

You can use loadkeys to switch to your preferred keyboard layout. (We even provide neo2 via loadkeys de neo!)

If the text is too small to be legible, try setfont ter-v32n to increase the font size.

To install over a serial port connect with 115200n8 (e.g. picocom -b 115200 /dev/ttyUSB0). When the bootloader lists boot entries, select the serial console boot entry.
Networking in the installer

The boot process should have brought up networking (check ip a). Networking is necessary for the installer, since it will download lots of stuff (such as source tarballs or Nixpkgs channel binaries). It’s best if you have a DHCP server on your network. Otherwise configure networking manually using ip.

You can configure the network, Wi-Fi included, through NetworkManager. Using the nmtui program, you can do so even in a non-graphical session. If you prefer to configure the network manually, disable NetworkManager with systemctl stop NetworkManager.

If you would like to continue the installation from a different machine you can use activated SSH daemon. You need to copy your ssh key to either /home/nixos/.ssh/authorized_keys or /root/.ssh/authorized_keys (Tip: For installers with a modifiable filesystem such as the sd-card installer image a key can be manually placed by mounting the image on a different machine). Alternatively you must set a password for either root or nixos with passwd to be able to login.
Partitioning and formatting

The NixOS installer doesn’t do any partitioning or formatting, so you need to do that yourself.

The NixOS installer ships with multiple partitioning tools. The examples below use parted, but also provides fdisk, gdisk, cfdisk, and cgdisk.

Use the command ‘lsblk’ to find the name of your ‘disk’ device.

The recommended partition scheme differs depending if the computer uses Legacy Boot or UEFI.
UEFI (GPT)

Here’s an example partition scheme for UEFI, using /dev/sda as the device.
Note

You can safely ignore parted’s informational message about needing to update /etc/fstab.

    Create a GPT partition table.

parted /dev/sda -- mklabel gpt

Add the root partition. This will fill the disk except for the end part, where the swap will live, and the space left in front (512MiB) which will be used by the boot partition.

parted /dev/sda -- mkpart root ext4 512MB -8GB

Next, add a swap partition. The size required will vary according to needs, here a 8GB one is created.

parted /dev/sda -- mkpart swap linux-swap -8GB 100%

Note

The swap partition size rules are no different than for other Linux distributions.

Finally, the boot partition. NixOS by default uses the ESP (EFI system partition) as its /boot partition. It uses the initially reserved 512MiB at the start of the disk.

parted /dev/sda -- mkpart ESP fat32 1MB 512MB

    parted /dev/sda -- set 3 esp on

    Note

    In case you decided to not create a swap partition, replace 3 by 2. To be sure of the id number of ESP, run parted --list.

Once complete, you can follow with the section called “Formatting”.
Legacy Boot (MBR)

Here’s an example partition scheme for Legacy Boot, using /dev/sda as the device.
Note

You can safely ignore parted’s informational message about needing to update /etc/fstab.

    Create a MBR partition table.

parted /dev/sda -- mklabel msdos

Add the root partition. This will fill the disk except for the end part, where the swap will live.

parted /dev/sda -- mkpart primary 1MB -8GB

Set the root partition’s boot flag to on. This allows the disk to be booted from.

parted /dev/sda -- set 1 boot on

Finally, add a swap partition. The size required will vary according to needs, here a 8GB one is created.

    parted /dev/sda -- mkpart primary linux-swap -8GB 100%

    Note

    The swap partition size rules are no different than for other Linux distributions.

Once complete, you can follow with the section called “Formatting”.
Formatting

Use the following commands:

    For initialising Ext4 partitions: mkfs.ext4. It is recommended that you assign a unique symbolic label to the file system using the option -L label, since this makes the file system configuration independent from device changes. For example:

mkfs.ext4 -L nixos /dev/sda1

For creating swap partitions: mkswap. Again it’s recommended to assign a label to the swap partition: -L label. For example:

mkswap -L swap /dev/sda2

UEFI systems

For creating boot partitions: mkfs.fat. Again it’s recommended to assign a label to the boot partition: -n label. For example:

    mkfs.fat -F 32 -n boot /dev/sda3

    For creating LVM volumes, the LVM commands, e.g., pvcreate, vgcreate, and lvcreate.

    For creating software RAID devices, use mdadm.

Installing

    Mount the target file system on which NixOS should be installed on /mnt, e.g.

mount /dev/disk/by-label/nixos /mnt

UEFI systems

Mount the boot file system on /mnt/boot, e.g.

mkdir -p /mnt/boot

mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

If your machine has a limited amount of memory, you may want to activate swap devices now (swapon device). The installer (or rather, the build actions that it may spawn) may need quite a bit of RAM, depending on your configuration.

swapon /dev/sda2

You now need to create a file /mnt/etc/nixos/configuration.nix that specifies the intended configuration of the system. This is because NixOS has a declarative configuration model: you create or edit a description of the desired configuration of your system, and then NixOS takes care of making it happen. The syntax of the NixOS configuration file is described in Configuration Syntax, while a list of available configuration options appears in Appendix A. A minimal example is shown in Example: NixOS Configuration.

This command accepts an optional --flake option, to also generate a flake.nix file, if you want to set up a flake-based configuration.

The command nixos-generate-config can generate an initial configuration file for you:

nixos-generate-config --root /mnt

You should then edit /mnt/etc/nixos/configuration.nix to suit your needs:

nano /mnt/etc/nixos/configuration.nix

If you’re using the graphical ISO image, other editors may be available (such as vim). If you have network access, you can also install other editors – for instance, you can install Emacs by running nix-env -f '<nixpkgs>' -iA emacs.

BIOS systems

    You must set the option boot.loader.grub.device to specify on which disk the GRUB boot loader is to be installed. Without it, NixOS cannot boot.

    If there are other operating systems running on the machine before installing NixOS, the boot.loader.grub.useOSProber option can be set to true to automatically add them to the grub menu.
UEFI systems

    You must select a boot-loader, either systemd-boot or GRUB. The recommended option is systemd-boot: set the option boot.loader.systemd-boot.enable to true. nixos-generate-config should do this automatically for new configurations when booted in UEFI mode.

    You may want to look at the options starting with boot.loader.efi and boot.loader.systemd-boot as well.

    If you want to use GRUB, set boot.loader.grub.device to nodev and boot.loader.grub.efiSupport to true.

    With systemd-boot, you should not need any special configuration to detect other installed systems. With GRUB, set boot.loader.grub.useOSProber to true, but this will only detect windows partitions, not other Linux distributions. If you dual boot another Linux distribution, use systemd-boot instead.

If you need to configure networking for your machine the configuration options are described in Networking. In particular, while wifi is supported on the installation image, it is not enabled by default in the configuration generated by nixos-generate-config.

Another critical option is fileSystems, specifying the file systems that need to be mounted by NixOS. However, you typically don’t need to set it yourself, because nixos-generate-config sets it automatically in /mnt/etc/nixos/hardware-configuration.nix from your currently mounted file systems. (The configuration file hardware-configuration.nix is included from configuration.nix and will be overwritten by future invocations of nixos-generate-config; thus, you generally should not modify it.) Additionally, you may want to look at Hardware configuration for known-hardware at this point or after installation.
Note

Depending on your hardware configuration or type of file system, you may need to set the option boot.initrd.kernelModules to include the kernel modules that are necessary for mounting the root file system, otherwise the installed system will not be able to boot. (If this happens, boot from the installation media again, mount the target file system on /mnt, fix /mnt/etc/nixos/configuration.nix and rerun nixos-install.) In most cases, nixos-generate-config will figure out the required modules.

Do the installation:

nixos-install

This will install your system based on the configuration you provided. If anything fails due to a configuration problem or any other issue (such as a network outage while downloading binaries from the NixOS binary cache), you can re-run nixos-install after fixing your configuration.nix.

If you opted for a flake-based configuration, you will need to pass the --flake here as well and specify the name of the configuration as used in the flake.nix file. For the default generated flake, this is nixos.

nixos-install --flake 'path/to/flake.nix#nixos'

As the last step, nixos-install will ask you to set the password for the root user, e.g.

setting root password...
New password: ***
Retype new password:***

If you have a user account declared in your configuration.nix and plan to log in using this user, set a password before rebooting, e.g. for the alice user:

nixos-enter --root /mnt -c 'passwd alice'

Note

For unattended installations, it is possible to use nixos-install --no-root-passwd in order to disable the password prompt entirely.

If everything went well:

    reboot

    You should now be able to boot into the installed NixOS. The GRUB boot menu shows a list of available configurations (initially just one). Every time you change the NixOS configuration (see Changing Configuration), a new item is added to the menu. This allows you to easily roll back to a previous configuration if something goes wrong.

    Use your declared user account to log in. If you didn’t declare one, you should still be able to log in using the root user.
    Note

    Some graphical display managers such as SDDM do not allow root login by default, so you might need to switch to TTY. Refer to User Management for details on declaring user accounts.

    You may also want to install some software. This will be covered in Package Management.

Installation summary

To summarise, Example: Commands for Installing NixOS on /dev/sda shows a typical sequence of commands for installing NixOS on an empty hard drive (here /dev/sda). Example: NixOS Configuration shows a corresponding configuration Nix expression.
Example 1. Example partition schemes for NixOS on /dev/sda (MBR)

Example 2. Example partition schemes for NixOS on /dev/sda (UEFI)

Example 3. Commands for Installing NixOS on /dev/sda

Exampl
e 4. Example: NixOS Configuration
