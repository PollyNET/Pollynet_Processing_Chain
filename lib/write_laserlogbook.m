function [] = write_laserlogbook(file, data, mode)
%write_laserlogbook create laserlogbook file with the given laserlogbook data.
%   Example:
%       [] = write_laserlogbook(file, data, mode)
%   Inputs:
%       file: char
%           absolute file path of the laserlogbook file.
%       data: struct
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
%       mode: char
%           file creation mode. 
%   Outputs:
%
%   References:
%       example of polly laserlogbook file:
% 2019-09-21 18:00:49SC,29233803	WT,28.6	HT,35	EO,8024	LS,310,1,0400	ER,OK,0400	EN,435	ExtPyro: 17.800 mJ	Temp1064: -30.5 C, Temp1: 30.1 C, Temp2: 31.4 C, OutsideRH: 60.7 %, OutsideT: 28.8 C, roof: 0, rain: 2, shutter: 4
% 2019-09-21 18:01:56SC,29235134	WT,28.6	HT,35	EO,8024	LS,310,1,0400	ER,OK,0400	EN,442	ExtPyro: 18.295 mJ	Temp1064: -30.5 C, Temp1: 30.0 C, Temp2: 31.2 C, OutsideRH: 60.3 %, OutsideT: 28.9 C, roof: 0, rain: 2, shutter: 4
%
%   History:
%       2019-09-28. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

fid = fopen(file, mode);

for iRow = 1:length(data.time)
    fprintf(fid, '%sSC,0\tExtPyro: %6.4f mJ\tTemp1064: %5.1f C, Temp1: %4.1f C, Temp2: %4.1f C, OutsideRH: %4.1f %%, OutsideT: %4.1f C\n', datestr(data.time(iRow), 'yyyy-mm-dd HH:MM:SS'), data.pyro(iRow), data.T1064(iRow), data.T1(iRow), data.T2(iRow), data.RHout(iRow), data.Tout(iRow));
end

fclose(fid);

end