% Código que va leyendo los fotogramas del vídeo de la panorámica y genera
% el Ground Truth
clear all
close all

scenario = 9;
PanRows = 1750;
PanCols = 3500;
NumFrames = 566;
if (scenario==5),    NumFrames = 600;   end
if (scenario==6)
    PanRows = 1440;
    PanCols = 2880;
    NumFrames = 600;
end
if (scenario==7)
    PanRows = 1024;
    PanCols = 2048;
    NumFrames = 600;
end
if (scenario==8 || scenario==9 || scenario==10)
    PanRows = 960;
    PanCols = 1920;
    NumFrames = 600;
end

NumChannels = 3;


pathFolderFramesVideo = '';


Matriz = zeros(PanRows,PanCols,NumChannels,NumFrames,'uint8');
GT = zeros(PanRows,PanCols,NumChannels,'double');


% Va esperando y leyendo los fotogramas

% for NdxFrame = 0:NumFrames-1
Frames = 1800:2:2999;
for NdxFrame = 0:NumFrames-1
    
    ThisFrame=Frames(NdxFrame+1);
    
    tic
    pathFolderFramesVideo = ...
        sprintf('../CarpetaCompartidaVM/litiv_vptz_icip2015/scenario%d/frames/scenario%d_%06d.jpg',...
            scenario,scenario,ThisFrame);
    
    while (~exist(pathFolderFramesVideo,'file'))
        pause(1)
    end
    
    Matriz(:,:,:,NdxFrame+1) = importdata(pathFolderFramesVideo);
 

end

GT = median(Matriz,4);
save(sprintf('GroundTruth_scenario%d_2.mat',scenario),'GT');

figure;
imshow(GT)
% saveas(gcf,'GT_scenario5.mat','png')


