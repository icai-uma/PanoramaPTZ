This directory contains a standalone version of the virtual PTZ library and executables used in
the 2015 ICIP paper 'Reproducible Evaluation of Pan-Tilt-Zoom Tracking'. Parts of it are derived
from the LITIV framework; visit https://github.com/plstcharles/litiv for more information.

The CMake project has been tested on Ubuntu 14.04 and should work on most platforms with a 
minimal amount of changes. It is based on OpenGL, and relies on GLFW or glut for window
management, GLEW for extension loading, and OpenCV for image processing functionalities.

The panoramic video dataset can be downloaded from Google Drive here:
  For full image sets (2.4 GB): https://drive.google.com/file/d/0B55Ba7lWTLh4QzNiOFFpSHFRNXM
  For .avi's only (68 MB): https://drive.google.com/file/d/0B55Ba7lWTLh4TFIxbHduU0hEb1U

Some OpenCV builds (depending on your FFmpeg-related choices) have trouble seeking back and
forth in image sequences and AVI files, so pick the dataset that fits your platform best. The
vptz library will check to see if seeking works before processing a sequence, so you will
automatically be notified if there is a problem.

See LICENSE.txt for terms of use and contact information.

