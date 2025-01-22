function [Model] = InitialTrainPTZ_RandomEnsemble_NG(Samples,Parameters,NdxFrame)
% Initial training of a competitive learning model, only the two first components of the
% samples are considered for the competition

global QT;

[Dimension,~]=size(Samples);

% Startup
NumNeuro=Parameters.NumNeurons;
Model.NumNeurons=NumNeuro;
Model.Dimension=Dimension;
Model.InitialLearningRate = Parameters.InitialLearningRate;
Model.NumSteps = Parameters.NumSteps;
Model.ConvergenceLearningRate = Parameters.ConvergenceLearningRate;
Model.PanRows = Parameters.PanRows;
Model.PanCols = Parameters.PanCols;

Model.NN = Parameters.NN;
Model.lambdaInit = Parameters.lambdaInit;
Model.lambdaFin = Parameters.lambdaFin;

rng(Parameters.seed);

% Inicializate prototypes
Model.Prototypes=zeros(Dimension,NumNeuro);
Model.Prototypes(1:2,:)=repmat([1;1],[1 NumNeuro])+...
    repmat([Parameters.PanRows-1;Parameters.PanCols-1],[1 NumNeuro]).*...
    rand(2,NumNeuro);

% Inicializate prototypes activations
Model.Activations = zeros(1,NumNeuro);



% Create Quadtree
eps = 0.001;
% BB = [-1.001, 1750.001, -1.001, 3500.001];
BB = [-1-eps, Model.PanRows+eps, -1-eps, Model.PanCols+eps];
QT = mexQuadtree(Model.Prototypes(1:2,:)',BB);


% Search winners prototypes
% NN = 1;
[QT_indices, ~] = QT.kNN_Search(Samples(1:2,:)',Model.NN);

% Update prototypes with the value of the samples
Model.Prototypes(3:5,QT_indices(:,1))=Samples(3:5,:);
Model.Activations(QT_indices(:,1)) = 1;

% Update the quad-tree
QT = QT.Update_Tree(Model.Prototypes(1:2,:)');



