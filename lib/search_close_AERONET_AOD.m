function [indx] = search_close_AERONET_AOD(lidarTime, AEROENTTime, minLag)
%search_close_AERONET_AOD search the closest AOD measurement index.
%   Example:
%       [indx] = search_close_AERONET_AOD(lidarTime, AEROENTTime, minLag)
%   Inputs:
%       lidarTime: datenum
%           lidar measurement time.
%       AEROENTTime: array
%           measurement time for each AERONET points. 
%       minLag: datenum
%           minimum lag.
%   Outputs:
%       indx: integer
%           index of the closest AERONET measurement point. If no required point was found, an empty array will be returned.
%   History:
%       2018-12-23. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

indx = [];

if isempty(AEROENTTime)
    return;
end

[tLag, thisIndx] = min(abs(AEROENTTime - lidarTime));

if tLag > minLag
    return;
else
    indx = thisIndx;
end

end