function depth = processXP1(data, plotNow)
%PROCESSXP1 process mearsure data
%
% copyright (c) wulx, wulx@mail.ustc.edu.cn

% last modified by wulx, 2014/2/19

if nargin<2, plotNow = false; end

xData = data(:, 1) * 1000; % unit: nm
zData = data(:, 2) / 10; % unit: nm

p = polyfit(xData, zData, 1);
zDataFitted = polyval(p, xData);

%#TODO Residuals and Goodness of Fit

% auto-Leveling in accordance with the fitted data
zDataLeveled = zData - zDataFitted;

mu1 = mean(zDataLeveled);
% mu2 = std(zDataLeveled);
% upperLim = mu1 + mu2;
% lowerLim = mu1 - mu2;

% select target points
[pks, pLocs] = findpeaks(zDataLeveled, 'THRESHOLD', 1); % peaks
[vls, vLocs] = findpeaks(-zDataLeveled, 'THRESHOLD', 1); % valleys

% classify target points
upperLocs = union(pLocs(pks>mu1), vLocs(vls<-mu1)); % in the grating line
lowerLocs = union(pLocs(pks<-mu1), vLocs(vls>mu1)); % in the groove

upperX = xData(upperLocs);
upperZ = zDataLeveled(upperLocs);

lowerX = xData(lowerLocs);
lowerZ = zDataLeveled(lowerLocs);

% upperP = polyfit(upperX, upperZ, 5);
% lowerP = polyfit(lowerX, lowerZ, 5);
upperSp = spap2(3, 4, upperX, upperZ);
lowerSp = spap2(3, 4, lowerX, lowerZ);

% inverse leveling to fit the original data
% upZFitted = polyval(upperP, xData)  + zDataFitted;
% loZFitted = polyval(lowerP, xData) + zDataFitted;
upZFitted = spval(upperSp, xData)  + zDataFitted;
loZFitted = spval(lowerSp, xData) + zDataFitted;

% distance between the upper line and lower, along Z-axis 
zDepth = upZFitted-loZFitted;
depth = mean(zDepth); % estimated depth

if plotNow
%     figure, hold on;
%     plot(xData, zData)
%     
%     plot(xData, zDataFitted)
%     
%     figure, hold on;
%     plot(xData, zDataLeveled)
%     
%     plot(xData, mu1*ones(size(xData)))
%     % plot(xData, upperLim*ones(size(xData)))
%     % plot(xData, lowerLim*ones(size(xData)))
%     
%     plot(upperX, upperZ, 'r.')
%     plot(lowerX, lowerZ, 'g.')
%     
    figure, hold on;
    plot(xData, zData)
    
    plot(xData, upZFitted)
    plot(xData, loZFitted)
    
%     figure, plot(xData, zDepth);
    title(['depth: ' num2str(depth)])
else
    disp(['depth: ' num2str(depth)])
end