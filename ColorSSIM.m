function [SSIM]=ColorSSIM(Image1,Image2)
% SSIM index for color images

ChannelSSIM=zeros(1,3);
for NdxChannel=1:3
    ChannelSSIM(NdxChannel)=ssim_index(squeeze(Image1(:,:,NdxChannel)),...
        squeeze(Image2(:,:,NdxChannel)));
end
SSIM=mean(ChannelSSIM);
