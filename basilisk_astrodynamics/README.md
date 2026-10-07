# Basilisk Astrodynamics with Space ROS

This demo shows how to use the [Basilisk astrodynamics framework](https://hanspeterschaub.info/basilisk/) with Space ROS Jazzy. It integrates the [Basilisk-ROS 2 Bridge](https://github.com/DISCOWER/bsk-ros2-bridge) and a [Basilisk-ROS 2 MPC](https://github.com/DISCOWER/bsk-ros2-mpc) in a containerized ROS 2 environment.

The included scenario is based on examples provided by the Basilisk-ROS 2 Bridge. It runs three spacecraft in Earth orbit with thruster-based actuation using force and torque commands. Each spacecraft is controlled by its own [acados](https://docs.acados.org)-based MPC, while the other two spacecraft are treated as collision-avoidance obstacles. An RViz window provides setpoint control for `bskSat0`, `bskSat1`, and `bskSat2`, while Vizard displays the Basilisk simulation.

<!-- Add media/basilisk_multi_agent_orbit.gif here.
<p align="center">
	<img src="media/basilisk_multi_agent_orbit.gif" alt="Three Basilisk spacecraft controlled through Space ROS" width="800">
</p>
<p align="center"><em>Three independently controlled spacecraft demonstrating position and attitude tracking with collision avoidance.</em></p>
-->

## Prerequisites

- Docker Engine with Docker Compose v2
- A Linux X11 desktop with `DISPLAY` and a readable `$XAUTHORITY`

RViz and Vizard use the host X11 display and GPU through `/dev/dri`. If the host does not provide a usable GPU device, start the demo with `LIBGL_ALWAYS_SOFTWARE=1 MESA_LOADER_DRIVER_OVERRIDE=llvmpipe ./run.sh`.

## Build

From this directory:

```bash
./build.sh
```

## Run

From this directory, start the demo:

```bash
./run.sh
```

`run.sh` starts the container and launches the following components inside it:

1. The Basilisk-ROS 2 Bridge
2. Three individual acados-based MPC controllers
3. The `scenarioRosMultiAgentOrbit_wrench.py` Basilisk scenario
4. Vizard visualization

To see the available runtime options:

```bash
./run.sh --help
```

Vizard is a Unity-based companion app for Basilisk that visualizes the running scenario. To run without Vizard:
```bash
./run.sh --no-vizard
```

Vizard can then be launched separately. In Vizard, select **Receive Only** and connect to the broadcast stream at `tcp://0.0.0.0:5570`.

RViz visualizes poses, trajectories, and collision-avoidance spheres, and provides interactive setpoint control for the MPCs. To run without RViz:

```bash
./run.sh --no-rviz
```

Without RViz, publish `geometry_msgs/msg/PoseStamped` setpoints to:

```text
/bskSat0/bsk_mpc/setpoint_pose
/bskSat1/bsk_mpc/setpoint_pose
/bskSat2/bsk_mpc/setpoint_pose
```

## Inspect the demo

From another terminal, open a shell in the running container:

```bash
docker compose exec basilisk bash
```

The component logs are available at:

```bash
tail -f /tmp/bridge.log
tail -f /tmp/mpc.log
tail -f /tmp/vizard.log
tail -f /tmp/basilisk.log
```

To inspect the ROS graph from that shell:

```bash
source /opt/ros/jazzy/setup.bash
source "${SPACEROS_DIR}/setup.bash"
source /opt/basilisk_ws/install/setup.bash
ros2 topic list
```

## Stop

From this directory:

```bash
docker compose down
```
