
                       Quadtree Implementation
                 (C) 01/14/2014, Shawn W. Walker

This code is open source under the BSD license (see the LICENSE.txt file).

DESCRIPTION
========================================================================

This code implements a point region (PR) quadtree for fast nearest neighbor searching.  It even beats MATLAB's KD-Tree!

USAGE
========================================================================

1. Extract the given .zip file and add the directory to the MATLAB path.  Also, add the sub-directory 'Unit_Test' to the MATLAB path.

2. You need a C++ compiler. I used MS Visual C++, express edition.  You can configure MATLAB to use a compatible C++ compiler by typing ``mex -setup'' at the MATLAB prompt.

3. Run the 'compile_quadtree_code.m' file.

4. Run the unit tests: 'run_unit_tests.m'.  Look at the unit tests to see how to use the code.

5. Any future versions of this code will be distributed in my FELICITY package (also available on the MATLAB Central File Exchange).


COMPATIBILITY NOTES
========================================================================
The tool was developed in its current form with R2013b.

You need a C++ compiler that MATLAB can use with its "mex" command.


Tested on these systems:

-- Windows XP, 32-bit
Fully functional with R2010b.

-- Windows 7, 64-bit
Fully functional with R2010b, R2013b.

-- LINUX KDE/Ubuntu, 64-bit
Fully functional with R2010b.


BUG REPORTS AND FEEDBACK
========================================================================
Please report any problems and/or bugs to:  walker@math.lsu.edu


ACKNOWLEDGEMENTS
========================================================================

This quadtree implementation is based on the following paper:

   S. F. Frisken and R. N. Perry,
   ``Simple and Efficient Traversal Methods for Quadtrees and Octrees,''
   Journal of Graphics Tools, 2002, Vol. 7, pg. 1-11

I also acknowledge this file on the MATLAB Central File Exchange:

http://www.mathworks.com/matlabcentral/fileexchange/38964-example-matlab-class-wrapper-for-a-c++-class
