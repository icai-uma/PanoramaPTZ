function [Indices, Dist] = kNN_Search(obj,pts,num_neighbor)
%kNN_Search
%
%   For each point in pts, this finds the closest point in the quadtree to it.
%
%   [Indices, Dist] = obj.kNN_Search(pts,num_neighbor)
%
%   pts          = Mx2 matrix of point coordinates.
%   num_neighbor = number of neighbors to return = K.
%
%   Indices = MxK matrix, where each row contains an integer index that indexes into the
%             rows of obj.Points.
%   Dist    = MxK matrix, similar to Indices except contains the corresponding distances.

% Copyright (c) 01-08-2014,  Shawn W. Walker

if (nargin < 3)
    num_neighbor = 1;
end

if (nargout <= 1)
    Indices = mexQuadtree_CPP('knn_search', obj.cppHandle, pts, num_neighbor);
    Dist = [];
else
    [Indices, Dist] = mexQuadtree_CPP('knn_search', obj.cppHandle, pts, num_neighbor);
end

end