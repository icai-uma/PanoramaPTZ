# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.4

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/bin/cmake

# The command to remove a file.
RM = /usr/local/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/ubuntu/virtualptz

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/ubuntu/virtualptz

# Include any dependencies generated for this target.
include execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/depend.make

# Include the progress variables for this target.
include execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/progress.make

# Include the compile flags for this target's objects.
include execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/flags.make

execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o: execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/flags.make
execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o: execs/vptz_gtviewer/src/main.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/ubuntu/virtualptz/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o"
	cd /home/ubuntu/virtualptz/execs/vptz_gtviewer && /usr/bin/c++   $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o -c /home/ubuntu/virtualptz/execs/vptz_gtviewer/src/main.cpp

execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/vptz_gtviewer.dir/src/main.cpp.i"
	cd /home/ubuntu/virtualptz/execs/vptz_gtviewer && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/ubuntu/virtualptz/execs/vptz_gtviewer/src/main.cpp > CMakeFiles/vptz_gtviewer.dir/src/main.cpp.i

execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/vptz_gtviewer.dir/src/main.cpp.s"
	cd /home/ubuntu/virtualptz/execs/vptz_gtviewer && /usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/ubuntu/virtualptz/execs/vptz_gtviewer/src/main.cpp -o CMakeFiles/vptz_gtviewer.dir/src/main.cpp.s

execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o.requires:

.PHONY : execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o.requires

execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o.provides: execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o.requires
	$(MAKE) -f execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/build.make execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o.provides.build
.PHONY : execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o.provides

execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o.provides.build: execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o


# Object files for target vptz_gtviewer
vptz_gtviewer_OBJECTS = \
"CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o"

# External object files for target vptz_gtviewer
vptz_gtviewer_EXTERNAL_OBJECTS =

build/bin/vptz_gtviewer: execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o
build/bin/vptz_gtviewer: execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/build.make
build/bin/vptz_gtviewer: build/lib/liblitiv_vptz.so
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_videostab.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_ts.a
build/bin/vptz_gtviewer: /usr/local/share/OpenCV/3rdparty/lib/libippicv.a
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_superres.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_stitching.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_shape.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_video.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_photo.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_objdetect.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_ml.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_calib3d.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_features2d.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_highgui.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_videoio.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_imgcodecs.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_imgproc.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_flann.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libopencv_core.so.3.0.0
build/bin/vptz_gtviewer: /usr/local/lib/libglfw3.a
build/bin/vptz_gtviewer: /usr/lib/x86_64-linux-gnu/libXrandr.so
build/bin/vptz_gtviewer: /usr/lib/x86_64-linux-gnu/libXxf86vm.so
build/bin/vptz_gtviewer: /usr/lib/x86_64-linux-gnu/libXcursor.so
build/bin/vptz_gtviewer: /usr/lib/x86_64-linux-gnu/libXinerama.so
build/bin/vptz_gtviewer: /usr/lib/x86_64-linux-gnu/libGLU.so
build/bin/vptz_gtviewer: /usr/lib/x86_64-linux-gnu/libGL.so
build/bin/vptz_gtviewer: /usr/lib/x86_64-linux-gnu/libGLEW.so
build/bin/vptz_gtviewer: execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/ubuntu/virtualptz/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable ../../build/bin/vptz_gtviewer"
	cd /home/ubuntu/virtualptz/execs/vptz_gtviewer && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/vptz_gtviewer.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/build: build/bin/vptz_gtviewer

.PHONY : execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/build

execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/requires: execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/src/main.cpp.o.requires

.PHONY : execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/requires

execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/clean:
	cd /home/ubuntu/virtualptz/execs/vptz_gtviewer && $(CMAKE_COMMAND) -P CMakeFiles/vptz_gtviewer.dir/cmake_clean.cmake
.PHONY : execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/clean

execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/depend:
	cd /home/ubuntu/virtualptz && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/ubuntu/virtualptz /home/ubuntu/virtualptz/execs/vptz_gtviewer /home/ubuntu/virtualptz /home/ubuntu/virtualptz/execs/vptz_gtviewer /home/ubuntu/virtualptz/execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : execs/vptz_gtviewer/CMakeFiles/vptz_gtviewer.dir/depend

