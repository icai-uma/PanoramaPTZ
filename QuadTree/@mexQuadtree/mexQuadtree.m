% FELICITY MATLAB class wrapper for a Quadtree C++ class
%
%   obj  = mexQuadtree(Points);
%   obj  = mexQuadtree(Points,Bounding_Box);
%   obj  = mexQuadtree(Points,Bounding_Box,Max_Tree_Levels);
%   obj  = mexQuadtree(Points,Bounding_Box,Max_Tree_Levels,Bucket_Size);
%
%   Points          = Mx2 matrix representing the coordinates of the points to be
%                     partitioned by the quadtree.
%   Bounding_Box    = bounding box dimensions of the points:
%                     1x4 vector [X_min, X_max, Y_min, Y_max].
%   Max_Tree_Levels = maximum number of tree levels to use in the quadtree.
%   Bucket_Size     = the number of points to store in each leaf cell of the quadtree.
classdef mexQuadtree < handle % this must be a sub-class of handle
    properties (SetAccess = private, Hidden = true)
        cppHandle         % Handle to the C++ class instance
    end
    properties (SetAccess = private)
        Points
        Bounding_Box
        Max_Tree_Levels
        Bucket_Size
    end
    methods
        % Constructor
        function obj = mexQuadtree(varargin)
            
            if or((nargin < 1),(nargin > 4))
                disp('Requires 1 to 4 arguments!');
                disp('First  is the point coordinates (Mx2 matrix).');
                disp('Second is the bounding box dimensions for the points: 1x4 vector [X_min, X_max, Y_min, Y_max].');
                disp('Third  is the maximum number of tree levels to use in the quadtree.');
                disp('Fourth is the bucket size to use for the number of points to store in each leaf cell.');
                error('Check the arguments!');
            end
            
            obj.Points = varargin{1};
            if (size(obj.Points,2)~=2)
                error('Points must have two columns!');
            end
            % get bounding box of points
            Min_X = min(obj.Points(:,1));
            Max_X = max(obj.Points(:,1));
            Min_Y = min(obj.Points(:,2));
            Max_Y = max(obj.Points(:,2));
            if (nargin >= 2)
                obj.Bounding_Box = varargin{2};
                BB = [Min_X, Max_X, Min_Y, Max_Y];
                BAD_BOX = (obj.Bounding_Box(1) > BB(1)) || (obj.Bounding_Box(2) < BB(2)) ||...
                          (obj.Bounding_Box(3) > BB(3)) || (obj.Bounding_Box(4) < BB(4));
                if (BAD_BOX)
                    disp('The user''s bounding box is:');
                    obj.Bounding_Box
                    disp('The actual bounding box of the points is:');
                    BB
                    disp('The user must specify a bounding box that *contains* the points!');
                    error('Check your inputs!');
                end
            else
                X_Diff = Max_X - Min_X;
                Y_Diff = Max_Y - Min_Y;
                % set bounding box coordinates to be slightly larger (default)
                obj.Bounding_Box = [Min_X - (0.001*X_Diff), Max_X + (0.001*X_Diff),...
                                    Min_Y - (0.001*Y_Diff), Max_Y + (0.001*Y_Diff)];
            end
            if (nargin >= 3)
                obj.Max_Tree_Levels = varargin{3};
                if (obj.Max_Tree_Levels < 2)
                    error('Max_Tree_Levels must be >= 2!');
                end
                if (obj.Max_Tree_Levels > 32)
                    error('Max_Tree_Levels must be <= 32!');
                end
            else
                obj.Max_Tree_Levels = 32; % default
            end
            if (nargin >= 4)
                obj.Bucket_Size = varargin{4};
                if (obj.Bucket_Size < 1)
                    error('Bucket_Size must be an integer > 0!');
                end
            else
                obj.Bucket_Size = 20; % default
            end
            % now create an instance of the C++ class
            % note: this will build the tree from the given points
            obj.cppHandle = mexQuadtree_CPP('new',obj.Points,obj.Bounding_Box,obj.Max_Tree_Levels,obj.Bucket_Size);
        end
        % Destructor - destroy the C++ class instance
        function delete(obj)
            mexQuadtree_CPP('delete', obj.cppHandle);
        end
        % Print_Tree - display the quadtree partition as ASCII text
        function Print_Tree(obj)
            mexQuadtree_CPP('print_tree', obj.cppHandle);
        end
    end
end

% END %