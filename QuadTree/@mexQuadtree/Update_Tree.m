function obj = Update_Tree(obj,new_pts)
%Update_Tree
%
%   This accepts a new set of points and updates the tree to accomodate the new point
%   coordinates.
%
%   obj = obj.Update_Tree(new_pts);
%
%   new_pts = Mx2 matrix of point coordinates.
%
%   Note: M must equal the number of rows of obj.Points, because this method replaces
%         obj.Points with new_pts.

% Copyright (c) 01-08-2014,  Shawn W. Walker

[nr, nc] = size(new_pts);
if (nr~=size(obj.Points,1))
    error('The number of points must be the same as the original set of points.');
end
if (nc~=2)
    error('The given points must be in 2-D (i.e. have 2 columns).');
end
if (nargout~=1)
    error('You must return the updated MATLAB object!');
end

obj.Points = new_pts; % overwrite points
mexQuadtree_CPP('update_tree', obj.cppHandle, obj.Points);

end