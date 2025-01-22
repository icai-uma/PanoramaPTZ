
project(vptz_backgroundModelling)
include_directories(${litiv_vptz_INCLUDE_DIR})
add_executable(vptz_backgroundModelling src/main.cpp)
target_link_libraries(vptz_backgroundModelling litiv_vptz)
