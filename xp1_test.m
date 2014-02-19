%% read XP-1 raw data
close all; clear all; clc

fileName = '#1.14.dat';

%% load raw data
% open the file
fileId = fopen(fileName, 'r');

% describe the data
% measTime: [Year, Month, Day, Hour, Minute, Second]

% #1 scan
% measTime = fscanf(fid, '"%d-%d-%d","%d:%d:%d"\n', 6);
% xUnits = fscanf(fid, '"X Units:","%[A-Z]"\n', 1);
% zUnits = fscanf(fid, '"Z Units:","%[A-Z]"\n', 1);
% otherParams = fscanf(fid, '"Num Data:",%d\n"Data Gain:",%d\n"Data Offset:",%d\n', 3);

% #2 line by line (from the start)
measTime = sscanf(fgetl(fileId), '"%d-%d-%d","%d:%d:%d"', 6);
xUnits = sscanf(fgetl(fileId), '"X Units:","%[A-Z]"', 1);
zUnits = sscanf(fgetl(fileId), '"Z Units:","%[A-Z]"', 1);
numData = sscanf(fgetl(fileId), '"Num Data:",%d', 1);
dataGain = sscanf(fgetl(fileId), '"Data Gain:",%d', 1);
dataOffset = sscanf(fgetl(fileId), '"Data Offset:",%d', 1);

data = fscanf(fileId, '%f,%f\n');

% close the file
fclose(fileId);

%% processing mearsure data
xData = data(1:2:end) * 1000; % unit: nm
zData = data(2:2:end) / 10; % unit: nm

% tricks: reduce the noisy signal
thres = [-inf, 300];
bandPass = (zData>thres(1)) & (zData<thres(2));
zData(~bandPass) = mean(zData(bandPass));

figure, hold on;
plot(xData, zData)

p = polyfit(xData, zData, 1);
zDataFitted = polyval(p, xData);

plot(xData, zDataFitted)

%#TODO Residuals and Goodness of Fit

% auto-Leveling in accordance with the fitted data
zDataLeveled = zData - zDataFitted;

figure, hold on;
plot(xData, zDataLeveled)


mu1 = mean(zDataLeveled);
mu2 = std(zDataLeveled);
upperLim = mu1 + mu2;
lowerLim = mu1 - mu2;

plot(xData, mu1*ones(size(xData)))
plot(xData, upperLim*ones(size(xData)))
plot(xData, lowerLim*ones(size(xData)))


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

plot(upperX, upperZ, 'r.')
plot(lowerX, lowerZ, 'g.')

upperP = polyfit(upperX, upperZ, 3);
lowerP = polyfit(lowerX, lowerZ, 3);

% inverse leveling to fit the original data
upZFitted = polyval(upperP, xData)  + zDataFitted;
loZFitted = polyval(lowerP, xData) + zDataFitted;

figure, hold on;
plot(xData, zData)

plot(xData, upZFitted)
plot(xData, loZFitted)

% distance between the upper line and lower, along Z-axis 
zDepth = upZFitted-loZFitted;
depth = mean(zDepth); % estimated depth

figure, plot(xData, zDepth);
title(['depth: ' num2str(depth)])
