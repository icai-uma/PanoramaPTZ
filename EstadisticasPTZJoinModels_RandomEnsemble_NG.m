% Script que calcula las estadísticas entre los métodos 
% (el del JoinModels NG 30%, uno sólo, el del JoinModels NG con 
% 50% y uno sólo, y los competidores) y el GT.
clear all
close all

addpath('./QuadTree/');

NumMethods = 7;
NumTests = 60;
scenario = 6;
GeneratePDF = 1;
MethodsLabels = {'RENG30','RENG50','NG30','NG50','linear','nearest','natural'};
MethodsPrefix = {'Our','Our','Our','Our','linear','nearest','natural'};
Results=[];
MyColors = distinguishable_colors(NumMethods+2);
ListSymbol={'h-','p-','o-','^-','s-','*-','d-','x-','+-','<-','v-'};

savePath = sprintf('./Results_RandomEnsemble_NG/scenario%d',scenario);
loadPath30 = './Ejecución_30%';
loadPath50 = './Ejecución_50%';

% Matriz para ir almacenando los panoramas de nuestro método
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
NumChannels = 3;
Seeds = 1:5;
NumSeeds = numel(Seeds);
INF = 1000;
Matriz = INF*ones(PanRows,PanCols,NumChannels,NumSeeds,'uint8');


% Define test samples (panoramic grid)
[pX,pY]=ndgrid(1:PanRows,1:PanCols);
TestSamples(1,:)=pX(:);
TestSamples(2,:)=pY(:);




% if (~exist(sprintf('Results_%d_from%d.mat',NumTests*50,RowStart),'file'))
if (~exist(sprintf('%s/Results_%d.mat',savePath,NumTests*50),'file'))

    load(sprintf('GroundTruth_scenario%d.mat',scenario))

    for NdxTest = 12:4:NumTests

        for NdxMethod = 1: NumMethods

            ThisMethod=MethodsLabels{NdxMethod};
            ThisPrefix=MethodsPrefix{NdxMethod};

            if strcmp(ThisMethod,'RENG30')==1
                
                JoinedModel.PanRows = PanRows;
                JoinedModel.PanCols = PanCols;
                JoinedModel.Prototypes = [];
                
                for NdxSeeds=1:NumSeeds
                    ThisSeed = Seeds(NdxSeeds);
                    path = sprintf('%s/OurMethod_scenario%d_seed%d',loadPath30,scenario,ThisSeed);
                    load(sprintf('%s/CLModel_seed%d_%dframes.mat',path,ThisSeed,NdxTest*50))
                    JoinedModel.Prototypes = [JoinedModel.Prototypes ...
                        CLModel.Prototypes(:,logical(CLModel.Activations))];
                end
                
                FlatReconstructedImage = TestPTZJoinModels_RandomEnsemble_NG(JoinedModel,TestSamples);
                ReconstructedImage=reshape(FlatReconstructedImage',[PanRows PanCols 3]);
                Image = ReconstructedImage*255;
                
                if (NdxTest==NumTests)
                    figure
                    imshow(uint8(Image))
                    saveas(gcf,sprintf('%s/OurMean30',savePath), 'png')
                end
                
            elseif strcmp(ThisMethod,'NG30')==1
                path = sprintf('%s/OurMethod_scenario%d_seed%d',loadPath30,scenario,1);
                load(sprintf('%s/%sMethod_%dframes.mat',path,ThisPrefix,NdxTest*50))
                
            elseif strcmp(ThisMethod,'RENG50')==1
                
                JoinedModel.PanRows = PanRows;
                JoinedModel.PanCols = PanCols;
                JoinedModel.Prototypes = [];
                
                for NdxSeeds=1:NumSeeds
                    ThisSeed = Seeds(NdxSeeds);
                    path = sprintf('%s/OurMethod_scenario%d_seed%d',loadPath50,scenario,ThisSeed);
                    load(sprintf('%s/CLModel_seed%d_%dframes.mat',path,ThisSeed,NdxTest*50))
                    JoinedModel.Prototypes = [JoinedModel.Prototypes ...
                        CLModel.Prototypes(:,logical(CLModel.Activations))];
                end
                
                FlatReconstructedImage = TestPTZJoinModels_RandomEnsemble_NG(JoinedModel,TestSamples);
                ReconstructedImage=reshape(FlatReconstructedImage',[PanRows PanCols 3]);
                Image = ReconstructedImage*255;
                
                if (NdxTest==NumTests)
                    figure
                    imshow(uint8(Image))
                    saveas(gcf,sprintf('%s/OurMean50',savePath), 'png')
                end
            
            elseif strcmp(ThisMethod,'NG50')==1
                path = sprintf('%s/OurMethod_scenario%d_seed%d',loadPath50,scenario,1);
                load(sprintf('%s/%sMethod_%dframes.mat',path,ThisPrefix,NdxTest*50))
            else
                path = sprintf('./CompetitorsEvolution_scenario%d/%s',scenario,ThisMethod);
                load(sprintf('%s/%sMethod_%dframes.mat',path,ThisPrefix,NdxTest*50))
            end
            

            Quality = RestorationQuality(double(GT),double(Image));

            Results.(ThisMethod).MSE(NdxTest)=Quality.MSE;
            Results.(ThisMethod).RMSE(NdxTest)=Quality.RMSE;
            Results.(ThisMethod).PSNR(NdxTest)=Quality.PSNR;
            Results.(ThisMethod).SSIM(NdxTest)=Quality.SSIM;
            Results.(ThisMethod).BC(NdxTest)=Quality.BC;

            fprintf('Results for %s method after %d frames:\n',ThisMethod,NdxTest*50);
            fprintf('MSE: %d\n',Quality.MSE);
            fprintf('SSIM: %d\n',Quality.SSIM);
            fprintf('BC: %d\n',Quality.BC);

        end
        
    end

    % CPUtime
    fprintf('Time results:\n');
    for NdxMethod = 1: NumMethods
        
        ThisPrefix=MethodsPrefix{NdxMethod};
        ThisMethod=MethodsLabels{NdxMethod};
        
        if strcmp(ThisMethod,'RENG30')==1
                
            for NdxSeeds=1:NumSeeds
                ThisSeed = Seeds(NdxSeeds);
                path = sprintf('%s/OurMethod_scenario%d_seed%d',loadPath30,scenario,ThisSeed);
                load(sprintf('%s/%sCPUtime.mat',path,ThisPrefix))
                CPU(NdxSeeds) = mean(CPUtime(2:end));
            end
            Results.(ThisMethod).CPUtime = mean(CPU);
            
            
        elseif strcmp(ThisMethod,'NG30')==1
            
            path = sprintf('%s/OurMethod_scenario%d_seed%d',loadPath30,scenario,1);
            load(sprintf('%s/%sCPUtime.mat',path,ThisPrefix))
            Results.(ThisMethod).CPUtime = mean(CPUtime(2:end));
            Results.(ThisMethod).CPUtimeStd = std(CPUtime(2:end));
            
        elseif strcmp(ThisMethod,'RENG50')==1

            for NdxSeeds=1:NumSeeds
                ThisSeed = Seeds(NdxSeeds);
                path = sprintf('%s/OurMethod_scenario%d_seed%d',loadPath50,scenario,ThisSeed);
                load(sprintf('%s/%sCPUtime.mat',path,ThisPrefix))
                CPU(NdxSeeds) = mean(CPUtime(2:end));
            end
            Results.(ThisMethod).CPUtime = mean(CPU);
            

        elseif strcmp(ThisMethod,'NG50')==1
            
            path = sprintf('%s/OurMethod_scenario%d_seed%d',loadPath50,scenario,1);
            load(sprintf('%s/%sCPUtime.mat',path,ThisPrefix))
            Results.(ThisMethod).CPUtime = mean(CPUtime(2:end));
            Results.(ThisMethod).CPUtimeStd = std(CPUtime(2:end));
            
        else
            
            path = sprintf('./CompetitorsEvolution_scenario%d/%s',scenario,ThisMethod);
            load(sprintf('%s/%s_CPUtime.mat',path,ThisPrefix))
            Results.(ThisMethod).CPUtime = mean(CPUtime(2:end));
            Results.(ThisMethod).CPUtimeStd = std(CPUtime(2:end));
            
        end
        
        
        fprintf('Mean CPU time for %s method:%d\n',ThisMethod,Results.(ThisMethod).CPUtime);        
        
    end
    
    
    
    save(sprintf('%s/Results_%d.mat',savePath,NumTests*50),'Results')
    
else
    load(sprintf('%s/Results_%d.mat',savePath,NumTests*50))
end


% PLOT FIGURES

%MSE
figure
hold on
for NdxMethod = 1:NumMethods

    ThisMethod=MethodsLabels{NdxMethod};
    
    plot([12:4:NumTests]*50,Results.(ThisMethod).MSE(12:4:end),ListSymbol{NdxMethod+2},...
        'Color',MyColors(NdxMethod+1,:),'MarkerSize',15-2*NdxMethod);
   
end
hold off
% breakyaxis([min(Results.linear.MSE(10:end)) max(Results.NG50.MSE(10:end))]);
% title('Comparision - MSE');
xlabel('NumFrames')
ylabel('MSE')
% legend(MethodsLabels)
if GeneratePDF 
    PdfFileName=sprintf('%s/MSE_Comparison_%d',savePath,scenario);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[9 8]);
    set(gcf,'PaperPosition',[0 0 9 8]);
    set(gca,'fontsize',10);
    saveas(gcf,PdfFileName,'pdf');
else
    legend(MethodsLabels)
    saveas(gcf,sprintf('%s/MSE_Comparison_%d',savePath,scenario), 'png')  %#ok<*UNRCH>
end



%SSIM
figure
hold on
for NdxMethod = 1: NumMethods

    ThisMethod=MethodsLabels{NdxMethod};
    
    plot([12:4:NumTests]*50,Results.(ThisMethod).SSIM(12:4:end),ListSymbol{NdxMethod+2},...
        'Color',MyColors(NdxMethod+1,:),'MarkerSize',15-2*NdxMethod);
    
end
hold off
% breakyaxis([14 21]);
% title('Comparision - SSIM');
xlabel('NumFrames')
ylabel('SSIM')
if GeneratePDF 
    PdfFileName=sprintf('%s/SSIM_Comparison_%d',savePath,scenario);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[9 8]);
    set(gcf,'PaperPosition',[0 0 9 8]);
    set(gca,'fontsize',10);
    saveas(gcf,PdfFileName,'pdf');
else
    legend(MethodsLabels)
    saveas(gcf,sprintf('%s/SSIM_Comparison_%d',savePath,scenario), 'png')  %#ok<*UNRCH>
end



%BC
figure
hold on
for NdxMethod = 1: NumMethods

    ThisMethod=MethodsLabels{NdxMethod};
    
    plot([12:4:NumTests]*50,Results.(ThisMethod).BC(12:4:end),ListSymbol{NdxMethod+2},...
        'Color',MyColors(NdxMethod+1,:),'MarkerSize',15-2*NdxMethod);
    
end
hold off
% breakyaxis([14 21]);
% title('Comparision - BC');

xlabel('NumFrames')
ylabel('BC')
if GeneratePDF 
    PdfFileName=sprintf('%s/BC_Comparison_%d',savePath,scenario);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[9 8]);
    set(gcf,'PaperPosition',[0 0 9 8]);
    set(gca,'fontsize',10);
    saveas(gcf,PdfFileName,'pdf');
else
    legend(MethodsLabels)
    saveas(gcf,sprintf('%s/BC_Comparison_%d',savePath,scenario), 'png')  %#ok<*UNRCH>
end



%CPU_TIME
NumMethodsTime = 5;
MethodsLabelsTime = {'NG30','NG50','linear','nearest','natural'};

figure
hold on
for NdxMethod = 1:NumMethodsTime

    ThisMethod=MethodsLabelsTime{NdxMethod};
%     errorbar(NdxMethod,Results.(ThisMethod).CPUtime,Results.(ThisMethod).CPUtimeStd,...
%         ListSymbol{NdxMethod+4},'Color',MyColors(NdxMethod+3,:),'MarkerSize',11-2*NdxMethod,...
%         'LineWidth',2);
    bar(NdxMethod,Results.(ThisMethod).CPUtime,'FaceColor',MyColors(NdxMethod+3,:));
    
end
hold off
set(gca,'xtick',1:NumMethodsTime)
set(gca,'xticklabel',MethodsLabelsTime)
xlabel('Methods')
ylabel('Time (sec/frame)')
if GeneratePDF 
    PdfFileName=sprintf('%s/CPUtime_Comparison_%d',savePath,scenario);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[9 8]);
    set(gcf,'PaperPosition',[0 0 9 8]);
    set(gca,'fontsize',10);
    saveas(gcf,PdfFileName,'pdf');
else
    legend(MethodsLabels)
    saveas(gcf,sprintf('%s/CPUtime_Comparison_%d',savePath,scenario), 'png')  %#ok<*UNRCH>
end
    

%MSE OURS
NumMethodsOurs = 4;
MethodsLabelsOurs = {'RENG30','RENG50','NG30','NG50'};

figure
hold on
for NdxMethod = 1:NumMethodsOurs

    ThisMethod=MethodsLabelsOurs{NdxMethod};
    
    plot([12:4:NumTests]*50,Results.(ThisMethod).MSE(12:4:end),ListSymbol{NdxMethod+2},...
        'Color',MyColors(NdxMethod+1,:),'MarkerSize',15-2*NdxMethod);
   
end
hold off
% breakyaxis([min(Results.linear.MSE(10:end)) max(Results.NG50.MSE(10:end))]);
% title('Comparision - MSE');
xlabel('NumFrames')
ylabel('MSE')
if GeneratePDF 
    PdfFileName=sprintf('%s/MSEOurs_Comparison_%d',savePath,scenario);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[9 8]);
    set(gcf,'PaperPosition',[0 0 9 8]);
    set(gca,'fontsize',10);
    saveas(gcf,PdfFileName,'pdf');
else
    legend(MethodsLabels)
    saveas(gcf,sprintf('%s/MSEOurs_Comparison_%d',savePath,scenario), 'png')  %#ok<*UNRCH>
end


%MSE BEST OURS vs COMPETITORS
NumMethodsOurs = 4;

figure
hold on
for NdxMethod = [2 5 6 7]

    ThisMethod=MethodsLabels{NdxMethod};
    
    plot([12:4:NumTests]*50,Results.(ThisMethod).MSE(12:4:end),ListSymbol{NdxMethod+2},...
        'Color',MyColors(NdxMethod+1,:),'MarkerSize',15-2*NdxMethod);
   
end
hold off
% breakyaxis([min(Results.linear.MSE(10:end)) max(Results.NG50.MSE(10:end))]);
% title('Comparision - MSE');
xlabel('NumFrames')
ylabel('MSE')
% legend({'RENG50','linear','nearest','natural'})
if GeneratePDF 
    PdfFileName=sprintf('%s/MSECompetitors_Comparison_%d',savePath,scenario);
    set(gcf,'PaperUnits','centimeters');
    set(gcf,'PaperOrientation','portrait');
    set(gcf,'PaperPositionMode','manual');
    set(gcf,'PaperSize',[9 8]);
    set(gcf,'PaperPosition',[0 0 9 8]);
    set(gca,'fontsize',10);
    saveas(gcf,PdfFileName,'pdf');
else
    legend(MethodsLabels)
    saveas(gcf,sprintf('%s/MSECompetitors_Comparison_%d',savePath,scenario), 'png')  %#ok<*UNRCH>
end



    