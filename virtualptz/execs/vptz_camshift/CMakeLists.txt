
project(vptz_camshift)
include_directories(${litiv_vptz_INCLUDE_DIR})
add_executable(vptz_camshift src/main.cpp)
target_link_libraries(vptz_camshift litiv_vptz glfw3 X11)
