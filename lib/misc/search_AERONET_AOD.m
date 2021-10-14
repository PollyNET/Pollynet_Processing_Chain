function [ind] = search_AERONET_AOD(lidarTime, AEROENTTime, minLag)
% SEARCH_AERONET_AOD search the closest AOD measurement index.
%
% USAGE:
%   [ind] = search_AERONET_AOD(lidarTime, AEROENTTime, minLag)
%
% INPUTS:
%   lidarTime: datenum
%       lidar measurement time.
%   AEROENTTime: array
%       measurement time for each AERONET points. 
%   minLag: datenum
%       minimum lag.
%
% OUTPUTS:
%   ind: integer
%       index of the closest AERONET measurement point. If no required point 
%       was found, an empty array will be returned.
%
% HISTORY:
%    - 2021-05-30: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

ind = [];

if isempty(AEROENTTime)
    return;
end

[tLag, thisInd] = min(abs(AEROENTTime - lidarTime));

if tLag > minLag
    return;
else
    ind = thisInd;
end

end