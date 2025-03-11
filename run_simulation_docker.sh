#!/bin/bash
# Parameters
ROBOT_NAME="adir"
CONTAINER_DOCUMENTS_PATH="/root/Documents"
ISAAC_SIM_VERSION="4.2.0"
CONTAINER_NAME="isaac-sim-$ROBOT_NAME-$RANDOM"

function set_default {
    # Set the default value of a variable if not already set
    eval "$1=\${$1:-$2}"
    echo "$1 = ${!1}"
}

# set the default values
echo "Using following settings:"
set_default ROS_DOMAIN_ID 0
set_default RMW_IMPLEMENTATION "rmw_cyclonedds_cpp"

# ---------------------------------------------------------------------------- #
#                                Docker Run Args                               #
# ---------------------------------------------------------------------------- #
# Get file path of the script
SCRIPT_PATH=$(realpath $0)
SCRIPT_DIR=$(dirname $SCRIPT_PATH)

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

DOCKER_RUN_ARGS=()
DOCKER_RUN_ARGS+=("--name $CONTAINER_NAME")
DOCKER_RUN_ARGS+=("-it")
DOCKER_RUN_ARGS+=("--rm")
DOCKER_RUN_ARGS+=("--network host")
DOCKER_RUN_ARGS+=("--runtime nvidia --gpus all")
DOCKER_RUN_ARGS+=("-e PRIVACY_CONSENT=Y")
DOCKER_RUN_ARGS+=("-e ACCEPT_EULA=Y")
DOCKER_RUN_ARGS+=("-e LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/isaac-sim/exts/omni.isaac.ros2_bridge/humble/lib")
DOCKER_RUN_ARGS+=("-e RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION")
DOCKER_RUN_ARGS+=("-e ROS_DOMAIN_ID=$ROS_DOMAIN_ID")
DOCKER_RUN_ARGS+=("-e ISAAC_SIM_HOME_DIR=/isaac-sim")
DOCKER_RUN_ARGS+=("--env XAUTHORITY=${XAUTH}")
DOCKER_RUN_ARGS+=("--env DISPLAY=${DISPLAY}")
DOCKER_RUN_ARGS+=("--volume $XSOCK:$XSOCK:rw")
DOCKER_RUN_ARGS+=("--volume $XAUTH:$XAUTH:rw ")
DOCKER_RUN_ARGS+=("-v $SCRIPT_DIR/docker/data/isaac-sim/cache/kit:/isaac-sim/kit/cache:rw")
DOCKER_RUN_ARGS+=("-v $SCRIPT_DIR/docker/data/isaac-sim/cache/ov:/root/.cache/ov:rw")
DOCKER_RUN_ARGS+=("-v $SCRIPT_DIR/docker/data/isaac-sim/cache/pip:/root/.cache/pip:rw")
DOCKER_RUN_ARGS+=("-v $SCRIPT_DIR/docker/data/isaac-sim/cache/glcache:/root/.cache/nvidia/GLCache:rw")
DOCKER_RUN_ARGS+=("-v $SCRIPT_DIR/docker/data/isaac-sim/cache/computecache:/root/.nv/ComputeCache:rw")
DOCKER_RUN_ARGS+=("-v $SCRIPT_DIR/docker/data/isaac-sim/logs:/root/.nvidia-omniverse/logs:rw")
DOCKER_RUN_ARGS+=("-v $SCRIPT_DIR/docker/data/isaac-sim/data:/root/.local/share/ov/data:rw")
DOCKER_RUN_ARGS+=("-v $SCRIPT_DIR:$CONTAINER_DOCUMENTS_PATH/$ROBOT_NAME:rw")
DOCKER_RUN_ARGS+=("--entrypoint /bin/bash ")

echo "load_simulation $CONTAINER_DOCUMENTS_PATH/$ROBOT_NAME/isaac_sim_scripts/load_simulation.py"
echo "file $CONTAINER_DOCUMENTS_PATH/$ROBOT_NAME/usd/world/full_warehouse.usd"
# Run the simulation
docker run ${DOCKER_RUN_ARGS[@]} nvcr.io/nvidia/isaac-sim:$ISAAC_SIM_VERSION -c "/isaac-sim/python.sh $CONTAINER_DOCUMENTS_PATH/$ROBOT_NAME/isaac_sim_scripts/load_simulation.py --file $CONTAINER_DOCUMENTS_PATH/$ROBOT_NAME/usd/world/full_warehouse.usd --no-headless"