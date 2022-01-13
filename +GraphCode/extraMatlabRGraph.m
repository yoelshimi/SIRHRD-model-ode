load('C:\Users\yoel\Dropbox\SocialStructureGraph\matlab\test\rand res for B 0.7 S 0.3 susc.mat')
res07 = res;
load('C:\Users\yoel\Dropbox\SocialStructureGraph\matlab\test\rand res for B 0.9 S 0.3 susc.mat')
res09 = res;
load('C:\Users\yoel\Dropbox\SocialStructureGraph\matlab\test\rand res for B 0.5 S 0.3 susc.mat')
res05 = res;
figure;
plotty(res05.R0matlab);
plotty(res07.R0matlab);
plotty(res09.R0matlab);

xlabel("correlation");
ylabel("matlab verified estimated growth rate")
title("rand res 0.3 susc B changing matlab grwoth raet sim");

function plotty(resData)
    method  = 1;
    mat     = squeeze(mean(resData(:,:,method),2));
    mat2    = squeeze(std(resData(:,:,method),0,2));
    
    c = linspace(-1,1,size(resData,1))
    errorbar(c, mat, mat2,'p'); hold on;
end