function [res] = pollly_read_temps(file)
%pollly_read_temps read the polly housekeeping data saved in a temporary file.
%   Example:
%       [res] = pollly_read_temps(file)
%   Inputs:
%       file: char
%           filename. (absolute filename)
%   Outputs:
%       res: struct
%           time: datenum array
%               log time.
%           T1064: array
%               temperature of the 1064 PMT
%           pyro: array
%               laser energy
%           T1: array
%           RH1: array
%           T2: array
%           RH2: array
%           Tout: array
%           RHout: array
%           Status: array
%           Dout: array
%   References:
%       example of polly temps file:
% Status sum: 1 -> roof closed, 2 -> no rain
% ==============================================================================
%           Time, UTC	 T1064	  pyro	    T1	   RH1	    T2	   RH2	  Tout	 RHout	 Status	  Dout
% 23.09.2019 00:00:01	 -31.3	  44.3	  25.0	  27.2	  24.4	  28.8	  18.5	  37.6	     7	     7
% 23.09.2019 00:00:05	 -31.2	  44.2	  25.0	  27.2	  24.5	  29.0	  18.5	  37.9	     7	     7
% 23.09.2019 00:00:10	 -31.3	  43.9	  25.0	  27.4	  24.6	  28.7	  18.6	  37.6	     7	     7
%
%   History:
%       2019-09-28. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

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

for iRow = 1:length(resRaw{1})
    res.time = [res.time, datenum(resRaw{1}{iRow}, 'dd.mm.yyyy HH:MM:SS')];
    res.T1064 = [res.T1064, resRaw{2}(iRow)];
    res.pyro = [res.pyro, resRaw{3}(iRow)];
    res.T1 = [res.T1, resRaw{4}(iRow)];
    res.RH1 = [res.RH1, resRaw{5}(iRow)];
    res.T2 = [res.T2, resRaw{6}(iRow)];
    res.RH2 = [res.RH2, resRaw{7}(iRow)];
    res.Tout = [res.Tout, resRaw{8}(iRow)];
    res.RHout = [res.RHout, resRaw{9}(iRow)];
    res.Status = [res.Status, resRaw{10}(iRow)];
    res.Dout = [res.Dout, resRaw{11}(iRow)];
end

fclose(fid);

end