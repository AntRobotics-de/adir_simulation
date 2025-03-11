#!/bin/bash

function set_default {
    # Set the default value of a variable if not already set
    eval "$1=\${$1:-$2}"
    echo "$1 = ${!1}"
}

# set the default values
echo "Using following settings:"
set_default ROS_DOMAIN_ID 0
set_default RMW_IMPLEMENTATION "rmw_cyclonedds_cpp"
set_default ISAAC_SIM_HOME_DIR "/home/$USER/.local/share/ov/pkg/isaac-sim-4.2.0"

export ROS_LOCALHOST_ONLY=0
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ISAAC_SIM_HOME_DIR/exts/omni.isaac.ros2_bridge/humble/lib"

$ISAAC_SIM_HOME_DIR/python.sh isaac_sim_scripts/load_simulation.py --file full_warehouse.usd --no-headless