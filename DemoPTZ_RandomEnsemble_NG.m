% Código que va leyendo los frames y entrenando una red neural gas
% Esta versión utiliza quadtrees y sólo tiene en cuenta las neuronas
% activadas, inicializándolas al valor de la muestra la primera vez que se
% active. Incluye 4 guardianes en las esquinas en el Test
% El parámetro landa varía linealmente en función del número de frames.

clear all
close all

addpath('./QuadTree/');

PanRows = 1750;
PanCols = 3500;
scenario = 10;
if (scenario==6)
    PanRows = 1440;
    PanCols = 2880;
end
if (scenario==7)
    PanRows = 1024;
    PanCols = 2048;
end
if (scenario==8 || scenario==9 || scenario==10)
    PanRows = 960;
    PanCols = 1920;
end
FrameRows = 480;
FrameCols = 640;

% Inicialization of the competitive net
NumPixels=FrameRows*FrameCols;
%FlatOriginalImage=reshape(OriginalImage,[NumPixels 3])';
TrainSamples=zeros(5,NumPixels);
% [X,Y]=ndgrid(1:size(OriginalImage,1),1:size(OriginalImage,2));

% Define model parameters
Parameters.NumSteps=1000;
Parameters.NumNeurons=round((PanRows*PanCols)*0.5);
Parameters.InitialLearningRate=0.4;
Parameters.ConvergenceLearningRate=0.01;
Parameters.PanRows = PanRows;
Parameters.PanCols = PanCols;
% Neural Gas parameters
Parameters.NN = 2;
Parameters.lambdaInit = 1;
Parameters.lambdaFin = 0.01;

% Random seed to initialize neurons
Parameters.seed = 5;

% Define test samples (panoramic grid)
[pX,pY]=ndgrid(1:PanRows,1:PanCols);
TestSamples(1,:)=pX(:);
TestSamples(2,:)=pY(:);

% Va esperando y leyendo los archivos binarios
numFrames = 3000;
InitModel = 1;
pathFolderFramesPTZ = '';

mkdir(sprintf('./OurMethod_scenario%d_seed%d/',scenario,Parameters.seed));

for NdxFrame = 0:numFrames-1
    
    tstart = tic;
    pathFolderFramesPTZ = sprintf('../BarridoFrames_scenario%d/MatFrame_%06d.bin',scenario,NdxFrame);
%     pathFolderFramesPTZ = sprintf('C:/Users/KarlK/Documents/IJCNN/CarpetaCompartidaVM/BarridoFrames/MatFrame_%06d.bin', NdxFrame);
    
    while (~exist(pathFolderFramesPTZ,'file'))
        pause(1)
    end
    
    fileID = fopen(pathFolderFramesPTZ,'r');
    VectorRaw = fread(fileID,4*640*480, 'uint8=>uint8');

    VectorRaw3D=reshape(VectorRaw,[4 FrameRows FrameCols]);
    VectorRaw3Dsinalpha=VectorRaw3D(1:3,:,:);
    Imagen3D=double(shiftdim(VectorRaw3Dsinalpha,1))/255;
%     imshow(Imagen3D)

    Ux = fread(fileID, FrameRows*FrameCols, 'double=>double');
    Vy = fread(fileID, FrameRows*FrameCols, 'double=>double');
    fclose(fileID);
    
    disp(pathFolderFramesPTZ)
    
    % Training
    scaledUx = Ux*(PanCols-1)+1;
    scaledVy = Vy*(PanRows-1)+1;
    
    TrainSamples(1,:)=scaledVy;
    TrainSamples(2,:)=scaledUx;
    TrainSamples(3:5,:)=reshape(Imagen3D,[NumPixels 3])';
    
    % Random mix of the samples
    TrainSamples=TrainSamples(:,randperm(size(TrainSamples,2)));
    
    if (InitModel == 1)
        CLModel = InitialTrainPTZ_RandomEnsemble_NG(TrainSamples,Parameters,1);
        InitModel = 0;       
        
    else
        CLModel = UpdateTrainPTZ_RandomEnsemble_NG(CLModel,TrainSamples,NdxFrame);
    end 
    CPUtime(NdxFrame+1) = toc(tstart);
    
    % Test every 50 frames
    if (mod(NdxFrame+1,50)==0)
        FlatReconstructedImage = TestPTZ_RandomEnsemble_NG(CLModel,TestSamples);
        ReconstructedImage=reshape(FlatReconstructedImage',[PanRows PanCols 3]);
        Image=uint8(ReconstructedImage*255);
        save(sprintf('./OurMethod_scenario%d_seed%d/OurMethod_%dframes.mat',scenario,...
            Parameters.seed,NdxFrame+1),'Image')
        
        % Save the Neural Model
        save(sprintf('./OurMethod_scenario%d_seed%d/CLModel_seed%d_%dframes.mat',...
            scenario,Parameters.seed,Parameters.seed,NdxFrame+1),'CLModel');
    end
    %     toc
    
    
    
%     %%% DEBUG
%     if (NdxFrame+1==1500)
%         
%         figure
%         plot(CLModel.Prototypes(2,:),CLModel.Prototypes(1,:),'or','MarkerSize',1);
%         axis([1 250 1 250])
%         saveas(gcf,sprintf('./OurMethod_scenario%d_seed%d/PrototypesMiddle.png',scenario,...
%             Parameters.seed), 'png')
%     end

    
    
    
end


% % Save the Neural Model
% save(sprintf('./OurMethod_scenario%d_seed%d/CLModel_seed%d.mat',...
%     scenario,Parameters.seed,Parameters.seed),'CLModel');



% %%% DEBUG
% figure
% plot(CLModel.Prototypes(2,:),CLModel.Prototypes(1,:),'or','MarkerSize',1);
% axis([1 250 1 250])
% saveas(gcf,sprintf('./OurMethod_scenario%d_seed%d/PrototypesEnd.png',scenario,...
%             Parameters.seed), 'png')


% Final test
tic
FlatReconstructedImage = TestPTZ_RandomEnsemble_NG(CLModel,TestSamples);
toc
ReconstructedImage=reshape(FlatReconstructedImage',[PanRows PanCols 3]);

figure;
imshow(ReconstructedImage)
saveas(gcf,sprintf('./OurMethod_scenario%d_seed%d/OurMethod_%dframes.png',scenario,...
            Parameters.seed,NdxFrame+1), 'png')

Image=uint8(ReconstructedImage*255);
save(sprintf('./OurMethod_scenario%d_seed%d/OurMethod_%dframes.mat',scenario,...
            Parameters.seed,NdxFrame+1),'Image')

save(sprintf('./OurMethod_scenario%d_seed%d/OurCPUtime.mat',scenario,Parameters.seed),'CPUtime');

% figure
% hold on
% for NdxProto=1:CLModel.NumNeurons
%     plot(CLModel.Prototypes(2,NdxProto),CLModel.Prototypes(1,NdxProto),'.g','Color',CLModel.Prototypes(3:5,NdxProto));
% end
% axis([0 3500 0 1750])
