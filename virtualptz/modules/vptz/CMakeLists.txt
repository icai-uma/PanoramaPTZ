
#
# Below are code snippets taken from the LITIV framework to form a standalone
# project for the virtual ptz library and executables.
#
# Copyright 2015 Pierre-Luc St-Charles; visit https://github.com/plstcharles/litiv
# for the full version and licensing information (provided under Apache 2.0 terms)
#

project(litiv_vptz)
set(LITIV_CURRENT_MODULE_NAME vptz)
set(LITIV_CURRENT_PROJECT_NAME litiv_vptz)

file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/include/litiv/${LITIV_CURRENT_MODULE_NAME}/StandaloneUtils.hpp)
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/include/litiv/${LITIV_CURRENT_MODULE_NAME}/StandaloneUtils.hpp.in"
    "${CMAKE_CURRENT_BINARY_DIR}/include/litiv/${LITIV_CURRENT_MODULE_NAME}/StandaloneUtils.hpp"
)

file(GLOB SOURCE_FILES
    "src/*.cpp"
)

file(GLOB INCLUDE_FILES
    "litiv/${LITIV_CURRENT_MODULE_NAME}/*.hpp"
    "litiv/${LITIV_CURRENT_MODULE_NAME}/*.ipp"
)

add_library(${LITIV_CURRENT_PROJECT_NAME} SHARED ${SOURCE_FILES})
add_definitions(-DVPTZ_EXPORT)
target_link_libraries(${LITIV_CURRENT_PROJECT_NAME} ${OpenCV_LIBRARIES})
if(USE_GLFW)
    target_link_libraries(${LITIV_CURRENT_PROJECT_NAME} ${GLFW_LIBRARIES})
elseif(USE_FREEGLUT)
    target_link_libraries(${LITIV_CURRENT_PROJECT_NAME} ${FREEGLUT_LIBRARY})
endif(USE_GLFW)
target_link_libraries(${LITIV_CURRENT_PROJECT_NAME} ${OPENGL_LIBRARIES})
target_link_libraries(${LITIV_CURRENT_PROJECT_NAME} ${GLEW_LIBRARIES})

target_include_directories(${LITIV_CURRENT_PROJECT_NAME}
    PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include/>"
    PUBLIC "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/>"
    INTERFACE "$<INSTALL_INTERFACE:include/>"
)

#install(TARGETS ${LITIV_CURRENT_PROJECT_NAME} DESTINATION lib)
install(FILES ${INCLUDE_FILES} DESTINATION include)
