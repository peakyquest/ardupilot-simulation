cmake_minimum_required(VERSION 3.8)
project(simulations)

find_package(ament_cmake REQUIRED)

# Install runtime assets so they can be found via ROS 2 package share paths.
install(
  DIRECTORY config launch models worlds
  DESTINATION share/${PROJECT_NAME}
  USE_SOURCE_PERMISSIONS
)

ament_package()
