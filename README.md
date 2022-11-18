# ros_installation_scripts

<br>

## Compatible Version Description

**ROS 1**
* Ubuntu 16.04 (Xenial Xerus) + ROS 1 Kinetic (EOL)
* Ubuntu 18.04 (Bionic Beaver) + ROS 1 Melodic
* Ubuntu 20.04 (Focal Fossa) + ROS 1 Noetic

**ROS 2**
* Ubuntu 16.04 (Xenial Xerus) + ROS 2 Dashing (EOL)
* Ubuntu 16.04 (Xenial Xerus) + ROS 2 Eloquent (EOL)
* Ubuntu 18.04 (Bionic Beaver) + ROS 2 Dashing (EOL)
* Ubuntu 18.04 (Bionic Beaver) + ROS 2 Eloquent (EOL)
* Ubuntu 20.04 (Focal Fossa) + ROS 2 Foxy
* Ubuntu 20.04 (Focal Fossa) + ROS 2 Galactic
* Ubuntu 22.04 (Jammy Jellyfish) + ROS 2 Humble

<br>

## Getting Started


### 1) Give Execution Permission
Let's make all script files executable.

```console
chmod -R +x ros_installation_scripts
```

### 2) Install ROS
Refer to the version description above and install the desired version of ROS.

**ROS 1**

<details>
<summary>Kinetic (EOL)</summary>

* To install `ros-kinetic-ros-base`, run the following command.
    ```console
    ./ros_installation_scripts/ros1/ros-kinetic-base.sh
    ```

* To install `ros-kinetic-desktop-full`, run the following command.
    ```console
    ./ros_installation_scripts/ros1/ros-kinetic-desktop-full.sh
    ```

</details>

<details>
<summary>Melodic</summary>

* To install `ros-melodic-ros-base`, run the following command.
    ```console
    ./ros_installation_scripts/ros1/ros-melodic-base.sh
    ```

* To install `ros-melodic-desktop-full`, run the following command.
    ```console
    ./ros_installation_scripts/ros1/ros-melodic-desktop-full.sh
    ```

</details>

<details>
<summary>Noetic</summary>

* To install `ros-noetic-ros-base`, run the following command.
    ```console
    ./ros_installation_scripts/ros1/ros-noetic-base.sh
    ```

* To install `ros-noetic-desktop-full`, run the following command.
    ```console
    ./ros_installation_scripts/ros1/ros-noetic-desktop-full.sh
    ```

</details>

<br>

**ROS 2**

<details>
<summary>Dashing (EOL)</summary>

* To install `ros-dashing-ros-base`, run the following command.
    ```console
    ./ros_installation_scripts/ros2/ros2-dashing-base.sh
    ``` 

* To install `ros-dashing-desktop`, run the following command.
    ```console
    ./ros_installation_scripts/ros2/ros2-dashing-desktop.sh
    ```

</details>

<details>
<summary>Eloquent (EOL)</summary>

* To install `ros-eloquent-ros-base`, run the following command.
    ```console
    ./ros_installation_scripts/ros2/ros2-eloquent-base.sh
    ``` 

* To install `ros-eloquent-desktop`, run the following command.
    ```console
    ./ros_installation_scripts/ros2/ros2-eloquent-desktop.sh
    ```

</details>

<details>
<summary>Foxy</summary>

* To install `ros-foxy-ros-base`, run the following command.
    ```console
    ./ros_installation_scripts/ros2/ros2-foxy-base.sh
    ``` 

* To install `ros-foxy-desktop`, run the following command.
    ```console
    ./ros_installation_scripts/ros2/ros2-foxy-desktop.sh
    ```

</details>

<details>
<summary>Galactic</summary>

* To install `ros-galactic-ros-base`, run the following command.
    ```console
    ./ros_installation_scripts/ros2/ros2-galactic-base.sh
    ``` 

* To install `ros-galactic-desktop`, run the following command.
    ```console
    ./ros_installation_scripts/ros2/ros2-galactic-desktop.sh
    ```

</details>

<details>
<summary>Humble</summary>

* To install `ros-humble-ros-base`, run the following command.
    ```console
    ./ros_installation_scripts/ros2/ros2-humble-base.sh
    ``` 

* To install `ros-humble-desktop`, run the following command.
    ```console
    ./ros_installation_scripts/ros2/ros2-humble-desktop.sh
    ```

</details>