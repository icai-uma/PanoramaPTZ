% Script que calcula las estadísticas entre los métodos y el GT
clear all

NumMethods = 7;
NumTests = 60;
scenarios = [3 5 6 7 8 9];
NumVideos = numel(scenarios);
GeneratePDF = 1;
MethodsLabels = {'NG30','NG50','RENG30','RENG50','linear','natural','nearest'};
% MethodsPrefix = {'Our','Our','Our','Our','linear','nearest','natural'};

for NdxScene = 1:NumVideos
    
    ThisScene = scenarios(NdxScene);
    
    savePath = sprintf('./Results_RandomEnsemble_NG/scenario%d',ThisScene);
    load(sprintf('%s/Results_%d.mat',savePath,NumTests*50))
    
    
    for NdxMethod = 1:NumMethods
        ThisMethod = MethodsLabels{NdxMethod};
        Stats.MSE(NdxMethod,NdxScene) = Results.(ThisMethod).MSE(end);
        Stats.SSIM(NdxMethod,NdxScene) = Results.(ThisMethod).SSIM(end);
        Stats.BC(NdxMethod,NdxScene) = Results.(ThisMethod).BC(end);
        Stats.CPU(NdxMethod,NdxScene) = Results.(ThisMethod).CPUtime(end);
        
%         if strcmp(ThisMethod,'Our')==1
%             path = sprintf('./OurMethod_scenario%d',ThisScene);
%         else
%             path = sprintf('./CompetitorsEvolution_scenario%d/%s',ThisScene,ThisMethod);
%         end
%         load(sprintf('%s/%s_CPUtime.mat',path,ThisMethod))
%         Stats.CPU(NdxMethod,NdxScene) = mean(CPUtime(2:end));
    end
    
end

disp('Mean MSE')
disp(mean(Stats.MSE,2))
disp('Std MSE')
disp(std(Stats.MSE,[],2))

disp('Mean SSIM')
disp(mean(Stats.SSIM,2))
disp('Std SSIM')
disp(std(Stats.SSIM,[],2))

disp('Mean BC')
disp(mean(Stats.BC,2))
disp('Std BC')
disp(std(Stats.BC,[],2))

disp('Mean CPUtime')
disp(mean(Stats.CPU,2))
disp('Std CPUtime')
disp(std(Stats.CPU,[],2))

    
    
    