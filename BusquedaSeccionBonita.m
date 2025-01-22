
clear all

scenario = 9;

load(sprintf('GroundTruth_scenario%d_2.mat',scenario))
load(sprintf('./BusquedaSeccionBonita/scenario%d/OurMethod30_3000frames.mat',scenario))
OurImage30 = Image;
load(sprintf('./BusquedaSeccionBonita/scenario%d/OurMethod50_3000frames.mat',scenario))
OurImage50 = Image;
importdata(sprintf('./BusquedaSeccionBonita/scenario%d/OurMean30.png',scenario));
OurImageMean30 = Image;
importdata(sprintf('./BusquedaSeccionBonita/scenario%d/OurMean50.png',scenario));
OurImageMean50 = Image;
load(sprintf('./BusquedaSeccionBonita/scenario%d/linearMethod_3000frames.mat',scenario))
linearImage = Image;
load(sprintf('./BusquedaSeccionBonita/scenario%d/nearestMethod_3000frames.mat',scenario))
nearestImage = Image;
load(sprintf('./BusquedaSeccionBonita/scenario%d/naturalMethod_3000frames.mat',scenario))
naturalImage = Image;

rSize = 50;
found = false;

% i=900;
% j=1250;

% for i = 1201:rSize:size(GT,1)-50
for i = 440:rSize:size(GT,1)-50
    
    for j = 1500:rSize:size(GT,2)-50
        
        QualityOur30 = RestorationQuality(double(GT(i:i+rSize-1,j:j+rSize-1,:)),...
            double(OurImage30(i:i+rSize-1,j:j+rSize-1,:)));
        
        QualityOur50 = RestorationQuality(double(GT(i:i+rSize-1,j:j+rSize-1,:)),...
            double(OurImage50(i:i+rSize-1,j:j+rSize-1,:)));
        
        QualityOurMean30 = RestorationQuality(double(GT(i:i+rSize-1,j:j+rSize-1,:)),...
            double(OurImageMean30(i:i+rSize-1,j:j+rSize-1,:)));
        
        QualityOurMean50 = RestorationQuality(double(GT(i:i+rSize-1,j:j+rSize-1,:)),...
            double(OurImageMean50(i:i+rSize-1,j:j+rSize-1,:)));
        
        QualityLinear = RestorationQuality(double(GT(i:i+rSize-1,j:j+rSize-1,:)),...
            double(linearImage(i:i+rSize-1,j:j+rSize-1,:)));
        
        QualityNearest = RestorationQuality(double(GT(i:i+rSize-1,j:j+rSize-1,:)),...
            double(nearestImage(i:i+rSize-1,j:j+rSize-1,:)));
        
        QualityNatural = RestorationQuality(double(GT(i:i+rSize-1,j:j+rSize-1,:)),...
            double(naturalImage(i:i+rSize-1,j:j+rSize-1,:)));
        
%         if QualityOurMean50.MSE < QualityLinear.MSE && QualityOurMean50.SSIM < QualityLinear.SSIM
        if QualityOurMean50.MSE < QualityLinear.MSE
            
            disp('MSE')
            disp(QualityOur30.MSE)
            disp(QualityOur50.MSE)
            disp(QualityOurMean30.MSE)
            disp(QualityOurMean50.MSE)
            disp(QualityLinear.MSE)
            disp(QualityNearest.MSE)
            disp(QualityNatural.MSE)
            disp('SSIM')
            disp(QualityOur30.SSIM)
            disp(QualityOur50.SSIM)
            disp(QualityOurMean30.SSIM)
            disp(QualityOurMean50.SSIM)
            disp(QualityLinear.SSIM)
            disp(QualityNearest.SSIM)
            disp(QualityNatural.SSIM)
            
            figure
            image(GT(i:i+rSize-1,j:j+rSize-1,:))
            axis off
            saveas(gcf,sprintf('./BusquedaSeccionBonita/scenario%d/GTsection.png',scenario),'png')
            figure
            image(OurImage30(i:i+rSize-1,j:j+rSize-1,:))
            axis off
            saveas(gcf,sprintf('./BusquedaSeccionBonita/scenario%d/Our30section.png',scenario),'png')
            figure
            image(OurImage50(i:i+rSize-1,j:j+rSize-1,:))
            axis off
            saveas(gcf,sprintf('./BusquedaSeccionBonita/scenario%d/Our50section.png',scenario),'png')
            figure
            image(OurImageMean30(i:i+rSize-1,j:j+rSize-1,:))
            axis off
            saveas(gcf,sprintf('./BusquedaSeccionBonita/scenario%d/OurRE30section.png',scenario),'png')
            figure
            image(OurImageMean50(i:i+rSize-1,j:j+rSize-1,:))
            axis off
            saveas(gcf,sprintf('./BusquedaSeccionBonita/scenario%d/OurRE50section.png',scenario),'png')
            figure
            image(linearImage(i:i+rSize-1,j:j+rSize-1,:))
            axis off
            saveas(gcf,sprintf('./BusquedaSeccionBonita/scenario%d/Linearsection.png',scenario),'png')
            figure
            image(nearestImage(i:i+rSize-1,j:j+rSize-1,:))
            axis off
            saveas(gcf,sprintf('./BusquedaSeccionBonita/scenario%d/Nearestsection.png',scenario),'png')
            figure
            image(naturalImage(i:i+rSize-1,j:j+rSize-1,:))
            axis off
            saveas(gcf,sprintf('./BusquedaSeccionBonita/scenario%d/Naturalsection.png',scenario),'png')
            
            found = true;
            pause;
        end
        
%         if (found==true), break; end
        
    end
    
%     if (found==true), break; end
    
end