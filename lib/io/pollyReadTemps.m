function [res] = pollyReadTemps(file)
% POLLYREADTEMPS read polly housekeeping data saved in a temporary file.
%
% USAGE:
%    [res] = pollyReadTemps(file)
%
% INPUTS:
%    file: char
%        filename. (absolute filename)
%
% OUTPUTS:
%    res: struct
%        time: datenum array
%            log time.
%        T1064: array
%            temperature of the 1064 PMT
%        pyro: array
%            laser energy
%        T1: array
%            temperature 1
%        RH1: array
%            RH 1
%        T2: array
%            temperature 2
%        RH2: array
%            RH 2
%        Tout: array
%            temperature outside
%        RHout: array
%            RH outside
%        Status: array
%            status
%        Dout: array
%            D outside
%
% HISTORY:
%    - 2019-09-28: First Edition by Zhenping
%    - 2021-02-14: Add error catch processing.
%
% .. Authors: - zhenping@tropos.de

%% initialization
res = struct();
res.time = [];
res.T1064 = [];
res.pyro = [];
res.T1 = [];
res.RH1 = [];
res.T2 = [];
res.RH2 = [];
res.Tout = [];
res.RHout = [];
res.Status = [];
res.Dout = [];

if exist(file, 'file') ~= 2
    warning('%s does not exist.', file);
    return;
end

fid = fopen(file, 'r');

resRaw = textscan(fid, '%s %f %f %f %f %f %f %f %f %f %f', ...
                  'delimiter', '\t', ...
                  'HeaderLines', 3);
fclose(fid);

try
    res.time = datenum(reshape(resRaw{1}, 1, []), 'dd.mm.yyyy HH:MM:SS');
    res.T1064 = resRaw{2};
    res.pyro = resRaw{3};
    res.T1 = resRaw{4};
    res.RH1 = resRaw{5};
    res.T2 = resRaw{6};
    res.RH2 = resRaw{7};
    res.Tout = resRaw{8};
    res.RHout = resRaw{9};
    res.Status = resRaw{10};
    res.Dout = resRaw{11};
catch
    warning('error in parsing %s. Please check it.', file);
    return;
end


end