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
  <a href="#eol-support">EOL support</a>
</p>

</div>

---

Choose a ROS distribution and an installation variant. The installer validates the host Ubuntu release before making system changes.

| Command | Ubuntu targets | Variants |
| :--- | :--- | :--- |
| `./install.sh <distribution> <base\|desktop>` | 10.04 Lucid Lynx through 26.04 Resolute Raccoon | `base`, `desktop` |

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
./install.sh rolling base # Rolling Ridley
```

The installer does not edit your shell startup files. Use the command printed after installation:

```bash
source /opt/ros/<distribution>/setup.bash
```

## Supported distributions

Each ROS distribution targets one canonical Ubuntu release. **EOL** entries are installed from their frozen final snapshot.

| Ubuntu | ROS 1 | ROS 2 |
| --- | --- | --- |
| 10.04 Lucid Lynx | <a href="https://wiki.ros.org/boxturtle"><img src="https://wiki.ros.org/boxturtle?action=AttachFile&amp;do=get&amp;target=Box_Turtle.320.png" height="48" align="middle" alt="Box Turtle artwork"></a>&nbsp;Box Turtle **EOL**<br><a href="https://wiki.ros.org/cturtle"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/cturtle.jpg" height="48" align="middle" alt="C Turtle artwork"></a>&nbsp;C Turtle **EOL**<br><a href="https://wiki.ros.org/diamondback"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/diamondback.jpg" height="48" align="middle" alt="Diamondback artwork"></a>&nbsp;Diamondback **EOL**<br><a href="https://wiki.ros.org/electric"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/electric.png" height="48" align="middle" alt="Electric Emys artwork"></a>&nbsp;Electric Emys **EOL** | — |
| 12.04 Precise Pangolin | <a href="https://wiki.ros.org/fuerte"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/fuerte.jpg" height="48" align="middle" alt="Fuerte Turtle artwork"></a>&nbsp;Fuerte Turtle **EOL**<br><a href="https://wiki.ros.org/groovy"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/groovy.jpg" height="48" align="middle" alt="Groovy Galapagos artwork"></a>&nbsp;Groovy Galapagos **EOL**<br><a href="https://wiki.ros.org/hydro"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/hydro.png" height="48" align="middle" alt="Hydro Medusa artwork"></a>&nbsp;Hydro Medusa **EOL** | — |
| 14.04 Trusty Tahr | <a href="https://wiki.ros.org/indigo"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/indigo.png" height="48" align="middle" alt="Indigo Igloo artwork"></a>&nbsp;Indigo Igloo **EOL**<br><a href="https://wiki.ros.org/jade"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/jade.png" height="48" align="middle" alt="Jade Turtle artwork"></a>&nbsp;Jade Turtle **EOL** | — |
| 16.04 Xenial Xerus | <a href="https://wiki.ros.org/kinetic"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/kinetic.png" height="48" align="middle" alt="Kinetic Kame artwork"></a>&nbsp;Kinetic Kame **EOL**<br><a href="https://wiki.ros.org/lunar"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/lunar_with_bg.png" height="48" align="middle" alt="Lunar Loggerhead artwork"></a>&nbsp;Lunar Loggerhead **EOL** | <a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Ardent-Apalone.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/ArdentApalone.png" height="48" align="middle" alt="Ardent Apalone artwork"></a>&nbsp;Ardent Apalone **EOL** |
| 18.04 Bionic Beaver | <a href="https://wiki.ros.org/melodic"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/melodic_with_bg.png" height="48" align="middle" alt="Melodic Morenia artwork"></a>&nbsp;Melodic Morenia **EOL** | <a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Bouncy-Bolson.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/bouncy.png" height="48" align="middle" alt="Bouncy Bolson artwork"></a>&nbsp;Bouncy Bolson **EOL**<br><a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Crystal-Clemmys.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/crystal.png" height="48" align="middle" alt="Crystal Clemmys artwork"></a>&nbsp;Crystal Clemmys **EOL**<br><a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Dashing-Diademata.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/dashing.png" height="48" align="middle" alt="Dashing Diademata artwork"></a>&nbsp;Dashing Diademata **EOL**<br><a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Eloquent-Elusor.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/eloquent.png" height="48" align="middle" alt="Eloquent Elusor artwork"></a>&nbsp;Eloquent Elusor **EOL** |
| 20.04 Focal Fossa | <a href="https://wiki.ros.org/noetic"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/noetic.png" height="48" align="middle" alt="Noetic Ninjemys artwork"></a>&nbsp;Noetic Ninjemys **EOL** | <a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Foxy-Fitzroy.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/foxy.png" height="48" align="middle" alt="Foxy Fitzroy artwork"></a>&nbsp;Foxy Fitzroy **EOL**<br><a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Galactic-Geochelone.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/galactic.png" height="48" align="middle" alt="Galactic Geochelone artwork"></a>&nbsp;Galactic Geochelone **EOL** |
| 22.04 Jammy Jellyfish | — | <a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Humble-Hawksbill.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/humble/HumbleHawksbill.png" height="48" align="middle" alt="Humble Hawksbill artwork"></a>&nbsp;Humble Hawksbill<br><a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Iron-Irwini.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/iron/IronIrwini_lowres.jpg" height="48" align="middle" alt="Iron Irwini artwork"></a>&nbsp;Iron Irwini **EOL** |
| 24.04 Noble Numbat | — | <a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Jazzy-Jalisco.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/jazzy/JazzyJalisco-noborder.png" height="48" align="middle" alt="Jazzy Jalisco artwork"></a>&nbsp;Jazzy Jalisco<br><a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Kilted-Kaiju.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/kilted/kilted-kaiju.png" height="48" align="middle" alt="Kilted Kaiju artwork"></a>&nbsp;Kilted Kaiju |
| 26.04 Resolute Raccoon | — | <a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Lyrical-Luth.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/lyrical/lyrical-luth.png" height="48" align="middle" alt="Lyrical Luth artwork"></a>&nbsp;Lyrical Luth<br><a href="https://docs.ros.org/en/ros2_documentation/lyrical/Releases/Release-Rolling-Ridley.html"><img src="https://raw.githubusercontent.com/openrobotics/artwork/4024191d62211c4d4fa024e9974dd372d92aa23a/distributions/rolling/rolling.png" height="48" align="middle" alt="Rolling Ridley artwork"></a>&nbsp;Rolling Ridley |

Humble Hawksbill, Jazzy Jalisco, Kilted Kaiju, and Lyrical Luth use the current official ROS repository. Rolling Ridley uses the official testing repository.

## Installation variants

| Variant | Intended use | Package family |
| --- | --- | --- |
| `base` | Headless systems, robots, and minimal installations | ROS base metapackage |
| `desktop` | Workstations that need GUI tools and common desktop packages | ROS 1 desktop-full or ROS 2 desktop |

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

## License

This repository is licensed under the [Apache License 2.0](LICENSE). ROS packages installed by this project remain subject to their respective licenses.

Distribution artwork by illustrator Joshua Ellingson is provided by [Open Robotics](https://github.com/openrobotics/artwork/tree/master/distributions) and the [ROS Wiki](https://wiki.ros.org/boxturtle) under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) and remains subject to the [ROS trademark policy](https://www.ros.org/blog/media/).
