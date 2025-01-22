function status = compile_quadtree_code()
%compile_quadtree_code
%
%    This compiles the mex file for a 2D point-region (PR) quadtree.  This is used for
%    point searches.

% Copyright (c) 01-14-2014,  Shawn W. Walker

Static_Dir = mfilename('fullpath');
Static_Dir = fileparts(Static_Dir);

Mesh_CPP    = fullfile(Static_Dir, 'src_code_quadtree', 'mexQuadtree.cpp');
Mesh_MEXDir = Static_Dir;
Mesh_MEX    = 'mexQuadtree_CPP';

disp('=======> Compile ''Quadtree point searcher''...');
status = feval(@mex, '-v', '-largeArrayDims', Mesh_CPP, '-outdir', Mesh_MEXDir, '-output', Mesh_MEX);
% % use this for debug
% status = feval(@mex, '-g', '-v', '-largeArrayDims', Mesh_CPP, '-outdir', Mesh_MEXDir, '-output', Mesh_MEX);

end