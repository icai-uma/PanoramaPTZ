% Código que va leyendo los frames y generando el panorama de los
% competidores

clear all
close all

scenario = 10;

PanRows = 1750;
PanCols = 3500;
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

% Inicialization of variables
NumPixels=FrameRows*FrameCols;
NumChannels = 3;
NumFrames = 3000;
InitModel = 1;
pathFolderFramesPTZ = '';
TrainSamples=zeros(5,NumPixels);
FotogramaTraducido = zeros(NumPixels,NumChannels);
Competidor = zeros(PanRows,PanCols,NumChannels);
NumCompetitors = 3;
CompetitorsLabels = {'linear','nearest','natural'};

Matriz = zeros(PanRows,PanCols,NumChannels,'double');
Contadores = zeros(PanRows,PanCols,NumChannels,'double');

NdxCompetitor = 3;
ThisCompetitor = CompetitorsLabels{NdxCompetitor};

mkdir(sprintf('./CompetitorsEvolution_scenario%d/',scenario))
mkdir(sprintf('./CompetitorsEvolution_scenario%d/%s/',scenario,ThisCompetitor))

% Va esperando y leyendo los archivos binarios
for NdxFrame = 0:NumFrames-1
    
    tstart = tic;
    % Open binary files
    pathFolderFramesPTZ = sprintf('../BarridoFrames_scenario%d/MatFrame_%06d.bin',scenario,NdxFrame);
    
    while (~exist(pathFolderFramesPTZ,'file'))
        pause(1)
    end
    
    fileID = fopen(pathFolderFramesPTZ,'r');
    VectorRaw = fread(fileID,4*640*480, 'uint8=>uint8');

    VectorRaw3D=reshape(VectorRaw,[4 FrameRows FrameCols]);
    VectorRaw3Dsinalpha=VectorRaw3D(1:3,:,:);
    Imagen3D=double(shiftdim(VectorRaw3Dsinalpha,1))/255;

    Ux = fread(fileID, FrameRows*FrameCols, 'double=>double');
    Vy = fread(fileID, FrameRows*FrameCols, 'double=>double');
    fclose(fileID);
    
    disp(pathFolderFramesPTZ)
    
    % Training
    scaledUx = Ux*(PanCols-1)+1;
    scaledVy = Vy*(PanRows-1)+1;
    
    % Rounding panorama coordinates
    X = round(scaledVy);
    Y = round(scaledUx);
    
    
    % Interpolation in the integer values of the panorama
    for NdxChannel = 1:3
        F = scatteredInterpolant(scaledVy,scaledUx,reshape(Imagen3D(:,:,NdxChannel),...
            [FrameRows*FrameCols 1]),ThisCompetitor);
        FotogramaTraducido(:,NdxChannel) = F(X,Y);
    end
%     FotogramaTraducido=reshape(FotogramaTraducido,[FrameRows FrameCols 3]);
%     imshow(FotogramaTraducido)
   
    % Add the cuurrent frame to the panorama
    Ipanorama=sub2ind(size(Matriz),repmat(X,[1 3]),repmat(Y,[1 3]),...
        [ones(size(X)) 2*ones(size(X)) 3*ones(size(X))]);
    Matriz(Ipanorama) = Matriz(Ipanorama)+FotogramaTraducido;
    Contadores(Ipanorama) = Contadores(Ipanorama)+1;
    
    CPUtime(NdxFrame+1) = toc(tstart);
    
    
    %Test
    if (mod(NdxFrame+1,50)==0)
        auxC = Contadores;
        auxC(auxC==0)=1;
        Competidor = Matriz./auxC;
        Image=uint8(Competidor*255);
        save(sprintf('./CompetitorsEvolution_scenario%d/%s/%sMethod_%dframes',...
            scenario,ThisCompetitor,ThisCompetitor,NdxFrame+1),'Image')

    end
    
end


% Compute the mean
Contadores(Contadores==0)=1;
Competidor = Matriz./Contadores;

figure;
imshow(Competidor)

saveas(gcf,sprintf('./CompetitorsEvolution_scenario%d/%s/%sMethod_%dframes',...
    scenario,ThisCompetitor,ThisCompetitor,NdxFrame+1),'png')

Image=uint8(Competidor*255);
save(sprintf('./CompetitorsEvolution_scenario%d/%s/%sMethod_%dframes',...
    scenario,ThisCompetitor,ThisCompetitor,NdxFrame+1),'Image')


save(sprintf('./CompetitorsEvolution_scenario%d/%s/%s_CPUtime',...
    scenario,ThisCompetitor,ThisCompetitor),'CPUtime');


