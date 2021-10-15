function data = multiscatter_model(filename)
% MULTISCATTER_MODEL running the mulple scattering model to calculate the 
% multiple scattering factor. Detailed information you can find in 
% '../lib/multiscatter.m'
%
% USAGE:
%    filename: char
%        the absolute path for the lidar configuration file. You can find 
%        an detailed information about the format and the multiple 
%        scattering model [here](http://www.met.reading.ac.uk/clouds/multiscatter/)
%
% INPUTS:
%    data: struct
%        range: array
%            apparent range above the ground. [m]
%        cloudExt: array
%            cloud extintion coefficient. [m^{-1}]
%        cloudRadius: array
%            cloud effective mean radius. [microns]
%        att_total: array
%            total attenuated backscatter. [m^{-1}*Sr^{-1}]
%        att_single: array
%            attenuated backscatter with single backscattering. 
%            [m^{-1}*Sr^{-1}]
%
% OUTPUTS:
%    data: struct
%        range
%        cloudExt
%        cloudRadius
%        att_total
%        att_single
%
% HISTORY:
%    - 2021-06-13: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

if exist(filename, 'file') ~= 2
    error('The configuration file does not exist.');
end

output_file1 = [tempname '.txt'];
output_file2 = [tempname '.txt'];

[s1, ~] = system([fullfile(fileparts(which('multiscatter_model')), ...
'script', 'multiscatter') ' -algorithms original lidar < ' ...
filename ' > ' output_file1]);
[s2, ~] = system([fullfile(fileparts(which('multiscatter_model')), ...
'script', 'multiscatter') ' -algorithms single lidar < ' ...
filename ' > ' output_file2]);

if ~ (s1 == 0) || ~ (s2 == 0)
    error('error in excuting multiscatter program.');
end

fid1 = fopen(output_file1, 'r');
data1 = fscanf(fid1, '%f %f %f %f %f', [5, Inf]);
data1 = data1';
fclose(fid1);
fid2 = fopen(output_file2, 'r');
data2 = fscanf(fid2, '%f %f %f %f %f', [5, Inf]);
data2 = data2';
fclose(fid2);

delete(output_file1);
delete(output_file2);

data.range = data1(:, 2);
data.cloudExt = data1(:, 3);
data.cloudRadius = data1(:, 4);
data.att_total = data1(:, 5);
data.att_single = data2(:, 5);

end