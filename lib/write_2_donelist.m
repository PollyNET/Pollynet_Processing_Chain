function [] = write_2_donelist(file, permission, lidar, location, startTime, stopTime, last_update, lambda, imageFile, level, thisinfo, nc_zip_file, nc_zip_file_size, active, GDAS1, GDAS1_timestamp, lidar_ratio, software_version, product_type, product_starttime, product_stoptime)
%write_2_donelist Write info of each generated pic to donelist file.
%   Example:
%       [] = write_2_donelist(file, permission, lidar, location, startTime, endTime, last_update, lambda, imageFile, level, thisinfo, nc_zip_file, nc_zip_file_size, active, GDAS1, GDAS1_timestamp, lidar_ratio, software_version, comment)
%   Inputs:
%       file: char
%           filename of the done list file. 
%       permission: char
%           file access type.
%       lidar: char
%           lidar label. Please go to /doc/pollynet.md for detailed information.
%       location: char
%           location of the current measurement campaign. This info can be found in /config/pollynet_processing_config_history.txt 
%       startTime: char
%           start time of the current measurement. (yyyy-mm-dd HH:MM:SS) 
%       stopTime: char
%           stop time for the current logged data file. (yyyy-mm-dd HH:MM:SS) 
%       last_update: char
%           last updated time for the image. (yyyy-mm-dd HH:MM:SS) 
%       lambda: char
%           wavelength label for the image. 
%       imageFile: char
%           relative directory of the image.
%      level: char
%          level of the image. (Need to be updated) 
%      thisinfo: char
%           information about the image. (like which configurations you've used for the retrieving.)
%      nc_zip_file: char
%           data file. 
%       nc_zip_file_size: char
%           size of the data file. 
%       active: char
%           flag to show whether the lidar is well operated. 
%       GDAS1: char
%           flag to show whether the GDAS1 data is used for the retrievign. 
%       GDAS1_timestamp: char
%           timestamp for the used GDAS1 file. (yyyymmddHH) 
%       lidar_ratio: char
%           lidar ratio. 
%       software_version: char
%           software version
%       product_type: char
%           identification for different lidar product. (Detailed information can be found in /doc/pollynet_processing_program.md)
%       product_starttime: char
%           the start time for the current product. (yyyymmdd HH:MM:SS)
%       product_stoptime: char
%           the stop time for the current product. (yyyymmdd HH:MM:SS)
%   Outputs:
%       
%   History:
%       2019-01-04. First Edition by Zhenping
%       2019-02-15. Add two params of 'product_starttime' and 'nproduct_stoptime'.
%       2019-03-12. Add input parameter of 'product_type' according to the requirement of new pollyWebApplication.
%   Contact:
%       zhenping@tropos.de

if ~ exist(file, 'file')
    warning('Done list file does not exist! For archiving the pic info, it will be created forcefully. \nDone list file: %s\n', file);
end

fid = fopen(file, permission);

fprintf(fid, 'lidar=%s\nlocation=%s\nstarttime=%s\nstoptime=%s\nlast_update=%s\nlambda=%s\nimage=%s\nlevel=%s\ninfo=%s\nnc_zip_file=%s\nnc_zip_file_size=%s\nactive=%s\nGDAS=%s\nGDAS_timestamp=%s\nlidar_ratio=%s\nsoftware_version=%s\nproduct_type=%s\nproduct_starttime=%s\nproduct_stoptime=%s\n------\n', lidar, location, startTime, stopTime, last_update, lambda, imageFile, level, thisinfo, nc_zip_file, nc_zip_file_size, active, GDAS1, GDAS1_timestamp, lidar_ratio, software_version, product_type, product_starttime, product_stoptime);

fclose(fid);

end