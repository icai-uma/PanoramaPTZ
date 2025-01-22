function Image=TestPTZ_RandomEnsemble_NG(Model,TestPoints)
% Test a competitive learning model, only the two first components of the
% samples are considered for the competition

% Select only the activated prototypes for testing
MyPrototypes = Model.Prototypes(:,logical(Model.Activations));



% Insert 4 guardians in the corners
% Create a quad-tree with the selected prototypes (we can't update)
eps = 0.001;
% BB = [-1.001, 1750.001, -1.001, 3500.001];
BB = [-1-eps, Model.PanRows+eps, -1-eps, Model.PanCols+eps];
QT = mexQuadtree(MyPrototypes(1:2,:)',BB);

% Search winner prototypes for the guardians
Guardians = [[1;1] [1;Model.PanCols]...
    [Model.PanRows;1] [Model.PanRows;Model.PanCols]];
NN = 1;
[QT_indices,~] = QT.kNN_Search(Guardians',NN);

% Update the set of prototypes
MyPrototypes = [MyPrototypes [Guardians;MyPrototypes(3:5,QT_indices)]];




NumSamples=size(TestPoints,2);
Image = zeros(3,NumSamples);

% Compute Delaunay triangulation of the plane
% tic
Triangulation=delaunayTriangulation(MyPrototypes(1:2,:)');
% toc

% Compute the indices of the triangles for the test points
% tic
[TriangleLocations,BarycentricCoordinates]=pointLocation(Triangulation,TestPoints');
% toc

% There are some infinite entries for those points outside all triangles
% TriangleLocations(~isfinite(TriangleLocations))=1;
finiteIndices = isfinite(TriangleLocations);

triangles = Triangulation.ConnectivityList(TriangleLocations(finiteIndices),:)';
% triangles = Triangulation(TriangleLocations(finiteIndices),:)';
% lambdas = BarycentricCoordinates(NdxSample,:);

rgb = reshape(MyPrototypes(3:5,triangles),[3 3 length(find(finiteIndices))]);
% rgb2 = reshape(rgb,[3 3 length(find(finiteIndices))]);
% rgb2 = reshape(rgb,[3 3 NumSamples]);


% By Karl
for NdxChannel = 1:3 % NumChannels
    
%     Image(i,:) = dot(BarycentricCoordinates',reshape(rgb2(i,:,:),[3 NumSamples]));
%     Image(NdxChannel,finiteIndices) = dot(BarycentricCoordinates',reshape(rgb2(NdxChannel,:,:),[3 length(find(finiteIndices))]));
    Image(NdxChannel,finiteIndices) = dot(BarycentricCoordinates(finiteIndices,:)',...
        reshape(rgb(NdxChannel,:,:),[3 length(find(finiteIndices))]));

end