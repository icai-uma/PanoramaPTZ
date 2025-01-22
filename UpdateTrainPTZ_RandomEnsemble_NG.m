function [Model]=UpdateTrainPTZ_RandomEnsemble_NG(Model,Samples,NdxFrame)
% Train a competitive learning model, only the two first components of the
% samples are considered for the competition

global QT;


% Training
if NdxFrame<Model.NumSteps   
        % Ordering phase: linear decay
        LearningRate=Model.InitialLearningRate*(1-NdxFrame/Model.NumSteps);
        
        lambda = Model.lambdaInit-(Model.lambdaInit-Model.lambdaFin)*(NdxFrame/Model.NumSteps);
        
    else
        % Convergence phase: constant(
        LearningRate=Model.ConvergenceLearningRate;
        
        lambda = Model.lambdaFin;
end

% Compute adaptation function
Model.adapFunction = exp(-(0:Model.NN-1)/lambda);

% Search winner prototypes
% NN = 1;
[QT_indices, ~] = QT.kNN_Search(Samples(1:2,:)',Model.NN);

% Find prototypes activated for the firs time
InitIndices = Model.Activations(QT_indices(:,1))==0;

% Update prototypes

% First, the winner neurons (just in case neuron need to be initialized)
Model.Prototypes(3:5,QT_indices(InitIndices,1))=Samples(3:5,InitIndices);
Model.Prototypes(:,QT_indices(~InitIndices,1))=(1-LearningRate*Model.adapFunction(1))*...
        Model.Prototypes(:,QT_indices(~InitIndices,1))+LearningRate*Model.adapFunction(1)*...
        Samples(:,~InitIndices);
% Update neighbour neurons    
for i=2:Model.NN
    Model.Prototypes(:,QT_indices(:,i))=(1-LearningRate*Model.adapFunction(i))*...
        Model.Prototypes(:,QT_indices(:,i))+LearningRate*Model.adapFunction(i)*Samples;
end

% Update prototypes activations
Model.Activations(QT_indices(:,1)) = 1;

% Update the quad-tree
QT = QT.Update_Tree(Model.Prototypes(1:2,:)');



