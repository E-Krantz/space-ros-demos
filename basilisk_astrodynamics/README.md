# Basilisk Astrodynamics with Space ROS

This demo shows how to use the Basilisk astrodynamics simulation with Space ROS
Jazzy. It integrates the
[Basilisk-ROS 2 Bridge](https://github.com/DISCOWER/bsk-ros2-bridge) and the
[Basilisk-ROS 2 MPC](https://github.com/DISCOWER/bsk-ros2-mpc) in a containerized
ROS 2 environment.

The included example runs three Basilisk spacecraft in Earth orbit. Each uses
the same ATMOS-inspired mass, inertia, and thruster model, with its own
wrench-level MPC and the other spacecraft supplied as collision-avoidance
agents. A single RViz window provides setpoint control for `bskSat0`, `bskSat1`,
and `bskSat2`, while Vizard displays the Basilisk simulation.

## Prerequisites

- Docker Engine with Docker Compose v2
- A Linux X11 desktop with `DISPLAY` configured
- A readable Xauthority file, normally `$HOME/.Xauthority`

The container uses the host GPU through `/dev/dri` for RViz and Vizard. If the
host does not provide a usable GPU device, start the demo with
`LIBGL_ALWAYS_SOFTWARE=1 MESA_LOADER_DRIVER_OVERRIDE=llvmpipe ./run.sh`.

## Build

From this directory:

```bash
./build.sh
```

## Run

Allow local Docker clients to connect to the X server and start the demo:

```bash
xhost +local:docker
./run.sh
```

`run.sh` starts the container and launches the following components inside it:

1. The Basilisk-ROS 2 Bridge
2. Three wrench MPC controllers using `multi_mpc.launch.py`
3. The `scenarioRosMultiAgentOrbit_wrench.py` Basilisk scenario
4. Vizard last, in DirectComm mode at `tcp://0.0.0.0:5556`

The MPC launch generates the acados solver code for the first controller and
reuses it for the remaining controllers.

Use the RViz interactive marker to select and command individual spacecraft.
The spacecraft namespaces are:

```text
/bskSat0
/bskSat1
/bskSat2
```

## Inspect the demo

Open a shell in the running container:

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

To inspect the ROS graph:

```bash
source /opt/ros/jazzy/setup.bash
source "${SPACEROS_DIR}/setup.bash"
source /opt/basilisk_ws/install/setup.bash
ros2 topic list
```

State topics include:

```text
/bskSat0/bsk/out/sc_states
/bskSat1/bsk/out/sc_states
/bskSat2/bsk/out/sc_states
```

## Stop

```bash
docker compose down
```

To revoke the X server permission afterward:

```bash
xhost -local:docker
```
