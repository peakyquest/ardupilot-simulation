import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, SetEnvironmentVariable
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration, PathJoinSubstitution, TextSubstitution
from launch_ros.actions import Node
from launch_ros.substitutions import FindPackageShare


def generate_launch_description():
    world = LaunchConfiguration("world")
    gz_verbose = LaunchConfiguration("gz_verbose")

    # ros_gz_sim/gz sim resolves assets (worlds/models) via GZ_SIM_RESOURCE_PATH.
    gz_resource_path_base = os.getenv("GZ_SIM_RESOURCE_PATH")
    if not gz_resource_path_base:
        raise RuntimeError(
            "GZ_SIM_RESOURCE_PATH is not set. Run the Gazebo setup script first "
            "or export it in your shell."
        )

    sim_share = get_package_share_directory("simulations")
    models_dir = os.path.join(sim_share, "models")
    worlds_dir = os.path.join(sim_share, "worlds")

    combined_resource_path = os.pathsep.join(
        [gz_resource_path_base, models_dir, worlds_dir]
    )

    # Full path to the SDF inside this ROS package (so it works without relying on env vars).
    world_path = PathJoinSubstitution(
        [FindPackageShare("simulations"), "worlds", world]
    )

    ros_gz_sim_launch_path = os.path.join(
        get_package_share_directory("ros_gz_sim"),
        "launch",
        "gz_sim.launch.py",
    )

    bridge_config_path = os.path.join(
        get_package_share_directory("simulations"),
        "config",
        "iris_gz_brdige.yaml",
    )

    return LaunchDescription(
        [
            SetEnvironmentVariable(
                name="GZ_SIM_RESOURCE_PATH",
                value=combined_resource_path,
            ),
            DeclareLaunchArgument(
                "world",
                default_value="iris_runway.sdf",
                description="SDF file name from simulations/worlds/",
            ),
            DeclareLaunchArgument(
                "gz_verbose",
                default_value="1",
                description="Gazebo verbosity for gz sim (-v <N>).",
            ),
            IncludeLaunchDescription(
                PythonLaunchDescriptionSource(ros_gz_sim_launch_path),
                launch_arguments={
                    "gz_args": [
                        TextSubstitution(text="-v"),
                        TextSubstitution(text=" "),
                        gz_verbose,
                        TextSubstitution(text=" -r "),
                        world_path,
                    ]
                }.items(),
            ),
            Node(
                package="ros_gz_bridge",
                executable="parameter_bridge",
                arguments=[
                    "--ros-args",
                    "-p",
                    f"config_file:={bridge_config_path}",
                ],
                output="screen",
            ),
        ]
    )

