function write_laserlogbook(file, data, mode)
% WRITE_LASERLOGBOOK create laserlogbook file with the given laserlogbook data.
%
% USAGE:
%   write_laserlogbook(file, data, mode)
%
% INPUTS:
%   file: char
%       absolute file path of the laserlogbook file.
%   data: struct
%       laserlogbook data.
%   mode: char
%       file creation mode.
%
% HISTORY:
%    - 2021-06-13: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

fid = fopen(file, mode);

for iRow = 1:length(data.time)
    fprintf(fid, '%sSC,0\tExtPyro: %6.4f mJ\tTemp1064: %5.1f C, Temp1: %4.1f C, Temp2: %4.1f C, OutsideRH: %4.1f %%, OutsideT: %4.1f C\n', datestr(data.time(iRow), 'yyyy-mm-dd HH:MM:SS'), data.pyro(iRow), data.T1064(iRow), data.T1(iRow), data.T2(iRow), data.RHout(iRow), data.Tout(iRow));
end

fclose(fid);

end