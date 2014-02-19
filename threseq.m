function zData = threseq(zData, thres)
%THRESEQ noisy data eqalization based on threshold or band pass
%
% copyright (c) wulx, wulx@mail.ustc.edu.cn

% last modified by wulx, 2014/2/18

bandPass = (zData>thres(1)) & (zData<thres(2));
zData(~bandPass) = mean(zData(bandPass));