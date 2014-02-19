function [data, measTime, xUnits, zUnits, numData, dataGain, dataOffset] = readXP1(fileName)
%READXP1 load raw data (AMBIOS XP-1)
% more details about AMBIOS XP-1: http://www.nano-fab.com/xp1.html
%
% copyright (c) wulx, wulx@mail.ustc.edu.cn

% last modified by wulx, 2014/2/18

% open the file
fileId = fopen(fileName, 'r');

% describe the data
% measTime: [Year, Month, Day, Hour, Minute, Second]

% #1 scanning directly
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

% two column, the first column contains X data and the second Z data
data = reshape(fscanf(fileId, '%f,%f\n'), 2, numData)';

% close the file
fclose(fileId);