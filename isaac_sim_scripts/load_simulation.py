import argparse
import carb
import os
from isaacsim import SimulationApp
import shutil
import glob

def copy_lidar_config():
    user = os.environ.get("USER")
    isaac_sim_home_dir = os.environ.get("ISAAC_SIM_HOME_DIR", f"/home/{user}/.local/share/ov/pkg/isaac-sim-4.2.0")
    isaac_sim_lidar_configs_dir = os.path.join(isaac_sim_home_dir, "exts", "omni.isaac.sensor", "data", "lidar_configs")
    local_lidar_configs_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "lidar_configs"))
    
    print(f"Copying lidar configs from {local_lidar_configs_dir} to {isaac_sim_lidar_configs_dir}")
    for file in glob.glob(os.path.join(local_lidar_configs_dir, "*.*")):
        shutil.copy2(
            file,
            isaac_sim_lidar_configs_dir,
        )
    
dir_root_path = dir_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "..")
parser = argparse.ArgumentParser(description="Load Isaac Sim with a specific scene")
parser.add_argument("-f", "--file", required=True, type=str, help="Path to the .usd file to load")
parser.add_argument("--headless", action=argparse.BooleanOptionalAction, help="Headless mode for Isaac Sim", default=True)
args, unknown = parser.parse_known_args()
file_path = os.path.abspath(os.path.join(dir_root_path, "usd", "world", args.file))
copy_lidar_config()
print("Loading Isaac Sim with file: ", file_path)
print("Headless mode: ", args.headless)

# This enables a livestream server to connect to when running headless
CONFIG = {
    "width": 1280,
    "height": 720,
    "window_width": 1920,
    "window_height": 1080,
    "headless": args.headless,
    "hide_ui": False,  # Show the GUI
    "renderer": "RayTracedLighting",
    "display_options": 3286,  # Set display options to show default grid
}

# Create the SimulationApp
simulation_app = SimulationApp(launch_config=CONFIG)

from omni.isaac.core.utils.extensions import enable_extension

# Default Livestream settings
simulation_app.set_setting("/app/window/drawMouse", True)
simulation_app.set_setting("/app/livestream/proto", "ws")
simulation_app.set_setting("/ngx/enabled", False)
# enable_extension("omni.kit.streamsdk.plugins-3.2.1")
# enable_extension("omni.kit.livestream.core-3.2.0")
# enable_extension("omni.kit.livestream.native")
# enable_extension("omni.services.streamclient.webrtc")

import omni
import omni.graph.core as og
from omni.isaac.core import SimulationContext
from omni.isaac.core.utils.nucleus import get_assets_root_path
from omni.isaac.core.utils.stage import is_stage_loading

# # enable ROS2 bridge extension
enable_extension("omni.isaac.ros2_bridge")
enable_extension("omni.kit.widget.stage")
enable_extension("omni.kit.widget.layers")
simulation_app.update()

omni.usd.get_context().open_stage(file_path, None)

# Wait two frames so that stage starts loading
simulation_app.update()
simulation_app.update()

print("Loading stage...")

while is_stage_loading():
   simulation_app.update()
print("Loading Complete")

simulation_context = SimulationContext(stage_units_in_meters=1.0)

simulation_context.play()
simulation_context.step()

while simulation_app._app.is_running() and not simulation_app.is_exiting():
    # Run in realtime mode, we don't specify the step size
    simulation_context.step()
    # simulation_app.update()

simulation_app.close()



