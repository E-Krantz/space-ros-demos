#!/usr/bin/env bash

set -euo pipefail

export XAUTHORITY="${XAUTHORITY:-${HOME}/.Xauthority}"

video_gid="$(getent group video | cut -d: -f3 || true)"
render_gid="$(getent group render | cut -d: -f3 || true)"
export VIDEO_GID="${VIDEO_GID:-${video_gid:-44}}"
export RENDER_GID="${RENDER_GID:-${render_gid:-110}}"

if [[ -z "${DISPLAY:-}" ]]; then
    echo "DISPLAY must be set for RViz and Vizard." >&2
    exit 1
fi

if [[ ! -r "${XAUTHORITY}" ]]; then
    echo "XAUTHORITY does not point to a readable file: ${XAUTHORITY}" >&2
    exit 1
fi

xhost +local:docker >/dev/null

docker compose down --remove-orphans
docker compose up -d

source_setup='source /opt/ros/jazzy/setup.bash && source "${SPACEROS_DIR}/setup.bash" && source /opt/basilisk_ws/install/setup.bash'

docker compose exec -T -d basilisk bash -lc "${source_setup} && ros2 launch bsk-ros2-bridge bridge.launch.py > /tmp/bridge.log 2>&1"
docker compose exec -T -d basilisk bash -lc "${source_setup} && ros2 launch bsk-ros2-mpc multi_mpc.launch.py agents:=\"bskSat0 bskSat1 bskSat2\" > /tmp/mpc.log 2>&1"
docker compose exec -T -d basilisk bash -lc "${source_setup} && python3 /opt/basilisk_test/scenarioRosMultiAgentOrbit_wrench.py > /tmp/basilisk.log 2>&1"
docker compose exec -T -d basilisk bash -lc "cd /opt/vizard && /usr/local/bin/Vizard.x86_64 --args -directComm tcp://0.0.0.0:5556 > /tmp/vizard.log 2>&1"

echo "Basilisk multi-agent demo started."
echo "Attach to the container with: docker compose exec basilisk bash"
echo "Component logs are in /tmp/bridge.log, /tmp/mpc.log, /tmp/vizard.log, and /tmp/basilisk.log."
