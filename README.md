# Adir Simulation
This repository uses NVIDIA's Isaac Sim for simulating the Adir robot.

### Prerequisites
- Docker
- NVIDIA Container Toolkit
- NVIDIA GPU with drivers installed
- NGC account
- ROS2 (Optional)

#### Steps to Login to Docker at nvcr.io
1. Create an NGC API Key:
   - Go to the NGC website.
   - Log in with your NGC account.
   - Navigate to the "Setup" page.
   - Click on "Get API Key" and generate a new key.
2. Login to Docker:
   - Open a terminal.
   - Run the following command to log in to the NVIDIA container registry:
   - When prompted, enter your NGC username and the API key as the password.
## Running the Simulation
Clone and Navigate to the project directory:
```bash
git clone https://github.com/AntRobotics-de/adir_simulation.git
cd adir_simulation
```
### with Docker (Recommended)
Run the Docker script:
```bash
./run_simulation_docker.sh
```

### Running the Simulation Locally
1. Edit the run_simulation_local.sh script:
   - Open the script in a text editor:
        ```bash
        nano run_simulation_local.sh
        ```

   - Update the ISAAC_SIM_HOME_DIR variable to the correct location of Isaac Sim on your system:
        ```bash
        set_default ISAAC_SIM_HOME_DIR "/path/to/your/isaac-sim"
        ```
        **Note**: Replace `/path/to/your/isaac-sim` with the actual path where Isaac Sim is installed on your system.
2. Run the local script:
   ```bash
   ./run_simulation_local.sh
   ```

## ROS2 Topics
The following ROS2 topics are used in the Adir simulation:

### Publishers
- `/adir/front/livox/lidar` (sensor_msgs/PointCloud2): Front LiDAR sensor data.
- `/adir/imu` (sensor_msgs/Imu): IMU sensor data.
- `/adir/odom` (nav_msgs/Odometry): Odometry data.
- `/adir/rear/livox/lidar` (sensor_msgs/PointCloud2): Rear LiDAR sensor data.
- `/clock` (rosgraph_msgs/Clock): Simulation clock.
- `/tf` (tf2_msgs/TFMessage): Transform data.
- `/tf_static` (tf2_msgs/TFMessage): Static transform data.

### Subscribers
- `/cmd_vel` (geometry_msgs/Twist): Command velocity for controlling the robot.