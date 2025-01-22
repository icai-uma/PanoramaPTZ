
project(vptz_gtviewer)
include_directories(${litiv_vptz_INCLUDE_DIR})
add_executable(vptz_gtviewer src/main.cpp)
target_link_libraries(vptz_gtviewer litiv_vptz glfw3 X11)
