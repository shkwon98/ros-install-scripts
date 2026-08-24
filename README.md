<div align="center">

<h1>ROS Install Scripts</h1>

<p><strong>Install any official ROS 1 or ROS 2 distribution on its canonical Ubuntu release with one command.</strong></p>

<p>
  <a href="https://github.com/shkwon98/ros-install-scripts/actions/workflows/ci.yml"><img alt="CI status" src="https://github.com/shkwon98/ros-install-scripts/actions/workflows/ci.yml/badge.svg"></a>
  <a href="#supported-distributions"><img alt="ROS 1 and ROS 2" src="https://img.shields.io/badge/ROS-1%20%26%202-22314E?logo=ros&logoColor=white"></a>
  <a href="#supported-distributions"><img alt="Ubuntu" src="https://img.shields.io/badge/Ubuntu-10.04%E2%80%9326.04-E95420?logo=ubuntu&logoColor=white"></a>
  <a href="#eol-support"><img alt="EOL releases" src="https://img.shields.io/badge/EOL-supported-6B7280"></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-Apache--2.0-D22128"></a>
</p>

<p>
  <a href="#quick-start">Quick start</a> ·
  <a href="#supported-distributions">Distributions</a> ·
  <a href="#installation-variants">Variants</a> ·
  <a href="#eol-support">EOL support</a> ·
  <a href="#limitations">Limitations</a>
</p>

</div>

---

Choose a ROS distribution and an installation variant. The installer validates the host Ubuntu release before making system changes.

| Command | Ubuntu targets | Variants |
| :--- | :--- | :--- |
| `./install.sh <distribution> <base\|desktop>` | 10.04 Lucid through 26.04 Resolute | `base`, `desktop` |

> [!IMPORTANT]
> This is a community project. It is not an official ROS or Ubuntu installer.

> [!WARNING]
> EOL distributions and their Ubuntu releases receive no security fixes. Use them only when compatibility requires it, preferably in an isolated environment.

## Quick start

### Prerequisites

- The exact Ubuntu release listed for your ROS distribution
- `sudo` access and an internet connection
- The Ubuntu `universe` component enabled

On a current Ubuntu release, enable `universe` with:

```bash
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y universe
```

Clone the repository and make the installer executable:

```bash
git clone https://github.com/shkwon98/ros-install-scripts.git
cd ros-install-scripts
chmod +x install.sh
```

Install a distribution:

```bash
./install.sh jazzy desktop
```

Other examples:

```bash
./install.sh noetic base   # EOL ROS 1
./install.sh iron desktop # EOL ROS 2
./install.sh rolling base # Rolling
```

The installer does not edit your shell startup files. Use the command printed after installation:

```bash
source /opt/ros/<distribution>/setup.bash
```

## Supported distributions

Each ROS distribution targets one canonical Ubuntu release. **EOL** entries are installed from their frozen final snapshot.

| Ubuntu | ROS 1 | ROS 2 |
| --- | --- | --- |
| 10.04 Lucid | Box Turtle **EOL**, C Turtle **EOL**, Diamondback **EOL**, Electric **EOL** | — |
| 12.04 Precise | Fuerte **EOL**, Groovy **EOL**, Hydro **EOL** | — |
| 14.04 Trusty | Indigo **EOL**, Jade **EOL** | — |
| 16.04 Xenial | Kinetic **EOL**, Lunar **EOL** | Ardent **EOL** |
| 18.04 Bionic | Melodic **EOL** | Bouncy **EOL**, Crystal **EOL**, Dashing **EOL**, Eloquent **EOL** |
| 20.04 Focal | Noetic **EOL** | Foxy **EOL**, Galactic **EOL** |
| 22.04 Jammy | — | Humble, Iron **EOL** |
| 24.04 Noble | — | Jazzy, Kilted |
| 26.04 Resolute | — | Lyrical, Rolling |

Humble, Jazzy, Kilted, and Lyrical use the current official ROS repository. Rolling uses the official testing repository.

## Installation variants

| Variant | Intended use | Package family |
| --- | --- | --- |
| `base` | Headless systems, robots, and minimal installations | ROS base metapackage |
| `desktop` | Workstations that need GUI tools and common desktop packages | ROS 1 desktop-full or ROS 2 desktop |

Early ROS distributions use different historical metapackage names:

| Distribution | `base` | `desktop` |
| --- | --- | --- |
| Box Turtle | `ros-boxturtle-base` | Not available |
| C Turtle | `ros-cturtle-base` | `ros-cturtle-all` |
| Diamondback and Electric | `ros-<distro>-ros-base` | `ros-<distro>-desktop-full` |
| Fuerte | `ros-fuerte-ros` | `ros-fuerte-desktop-full` |
| Groovy through Noetic | `ros-<distro>-ros-base` | `ros-<distro>-desktop-full` |
| ROS 2 | `ros-<distro>-ros-base` | `ros-<distro>-desktop` |

`./install.sh boxturtle desktop` is rejected before system changes because no general desktop metapackage exists in the final Box Turtle snapshot.

## EOL support

EOL distributions use the signed final repositories at `snapshots.ros.org`. The installer downloads the ROS Snapshot Builder public key from Ubuntu's keyserver and accepts it only when its complete fingerprint matches:

```text
4B63 CF8F DE49 746E 98FA 01DD AD19 BAB3 CBF1 25EA
```

The snapshot repository uses HTTP because its current TLS certificate does not match the hostname. Apt signature verification remains enabled; the installer never uses `trusted=yes` or unauthenticated package installation.

Your Ubuntu package sources must already work. For an EOL Ubuntu release, configure its archived sources and include the `universe` component before running the installer.

## How installation works

1. Validate the distribution, variant, Ubuntu release, and `universe` component.
2. Configure the official current, testing, or final snapshot repository.
3. Confirm that the selected metapackage exists for the current architecture.
4. Install the metapackage and verify `/opt/ros/<distribution>/setup.bash`.
5. Print the shell command needed to use the installation.

## Limitations

- Ubuntu only; every ROS distribution supports the single Ubuntu target shown above.
- EOL installation requires working archived Ubuntu sources and HTTPS access to `keyserver.ubuntu.com`. Very old TLS stacks may not connect.
- Package and architecture availability is limited to what the selected ROS repository retains.
- The installer does not initialize rosdep, install development tools, upgrade Ubuntu, or persist shell configuration.
- CI checks Bash syntax, ShellCheck, and non-privileged behavior. It does not perform full ROS installations.

## License

This repository is licensed under the [Apache License 2.0](LICENSE). ROS packages installed by this project remain subject to their respective licenses.
