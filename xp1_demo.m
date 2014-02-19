%% xp1 demo
close all; clear all; clc

dataFiles = fullfile(pwd, '*.dat');

F = dir( dataFiles );
fileNames = { F.name };
nFiles = numel(fileNames);

depth = nan(nFiles, 1);
for i = 1:nFiles
    fileName = fileNames{i};
    disp(['file name: ' fileName])
    
    data = readXP1(fileName);
    
    if isequal(fileName, '#1.14.dat') % remove noisy peaks
        data(:,2) = threseq(data(:,2), [-inf, 3000]);
    end
    
    depth(i) = processXP1(data, true);
end

depth2 = reshape(depth, 7, nFiles/7);
depth2(:, 3:4) = depth2(end:-1:1, 4:-1:3); % rotation for #2

figure, hold on;
ribbon(depth2)
legend('#1.1', '#1.2', '#2.1', '#2.2', '#3.1', '#3.2', '#4.1', '#4.2')