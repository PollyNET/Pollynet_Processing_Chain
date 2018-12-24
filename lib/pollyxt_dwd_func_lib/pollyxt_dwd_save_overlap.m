function [] = pollyxt_dwd_save_overlap(height, overlap532, overlap355, overlap532Defaults, overlap355Defaults, file, config, globalAttri)
%pollyxt_dwd_save_overlap Save the overlap file.
%   Example:
%       [] = pollyxt_dwd_save_overlap(height, overlap532, overlap355, overlap532Defaults, overlap355Defaults, file, config, globalAttri);
%   Inputs:
%       height: array
%           height above surface. [m]
%       overlap532: array
%           calculated overlap for 532 nm far range total channel.
%       overlap355: array
%           calculated overlap for 355 nm far range total channel.
%       overlap532Defaults: array
%           default overlap for 532 nm far range total channel.
%       overlap355Defaults: array
%           default overlap for 355 nm far range total channel.
%       file: char
%           netcdf file to save the overlap parameters.
%       config: struct
%           polly processing configuration. More detailed information can be found in doc/polly_config.md
%       globalAttri: struct
%           global attribute.
%   Outputs:
%       
%   History:
%       2018-12-21. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

% convert empty array to defaults
if isempty(overlap532)
    overlap532 = -999 * ones(size(height));
end
if isempty(overlap355)
    overlap355 = -999 * ones(size(height));
end
if isempty(overlap355Defaults)
    overlap355Defaults = -999 * ones(size(height));
end
if isempty(overlap532Defaults)
    overlap532Defaults = -999 * ones(size(height));
end

% Create .nc file by overwriting any existing file with the name filename
ncID = netcdf.create(file, 'CLOBBER');

% define dimensions
dimID_height = netcdf.defDim(ncID, 'height', length(height));
dimID_method = netcdf.defDim(ncID, 'method', 1);

% define variables
varID_height = netcdf.defVar(ncID, 'height', 'double', dimID_height);
varID_overlap532 = netcdf.defVar(ncID, 'overlap532', 'double', dimID_height);
varID_overlap355 = netcdf.defVar(ncID, 'overlap355', 'double', dimID_height);
varID_overlap532Defaults = netcdf.defVar(ncID, 'overlap532Defaults', 'double', dimID_height);
varID_overlap355Defaults = netcdf.defVar(ncID, 'overlap355Defaults', 'double', dimID_height);
varID_overlapCalMethod = netcdf.defVar(ncID, 'method', 'int32', dimID_method);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_height, height);
netcdf.putVar(ncID, varID_overlap532, overlap532);
netcdf.putVar(ncID, varID_overlap355, overlap355);
netcdf.putVar(ncID, varID_overlap532Defaults, overlap532Defaults);
netcdf.putVar(ncID, varID_overlap355Defaults, overlap355Defaults);
netcdf.putVar(ncID, varID_overlapCalMethod, config.overlapCorMode);

% re enter define mode
netcdf.reDef(ncID);

% write attributes to the variables
netcdf.putAtt(ncID, varID_height, 'unit', 'm');
netcdf.putAtt(ncID, varID_height, 'long_name', 'height (above surface)');

netcdf.putAtt(ncID, varID_overlap532, 'unit', '');
netcdf.putAtt(ncID, varID_overlap532, 'long_name', 'overlap function for 532nm far-range channel');

netcdf.putAtt(ncID, varID_overlap355, 'unit', '');
netcdf.putAtt(ncID, varID_overlap355, 'long_name', 'overlap function for 355nm far-range channel');

netcdf.putAtt(ncID, varID_overlap355Defaults, 'unit', '');
netcdf.putAtt(ncID, varID_overlap355Defaults, 'long_name', 'Default overlap function for 355nm far-range channel');

netcdf.putAtt(ncID, varID_overlap532Defaults, 'unit', '');
netcdf.putAtt(ncID, varID_overlap532Defaults, 'long_name', 'Default overlap function for 532nm far-range channel');

netcdf.putAtt(ncID, varID_overlapCalMethod, 'unit', '');
netcdf.putAtt(ncID, varID_overlapCalMethod, 'long_name', '1: signal ratio of near and far range signal; 2: Raman method (Ulla Wandinger 2002)');

varID_global = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncID, varID_global, 'location', globalAttri.location);
netcdf.putAtt(ncID, varID_global, 'institution', globalAttri.institution);
netcdf.putAtt(ncID, varID_global, 'contact', sprintf('If you have any question about the calibration process, please send email to %s', globalAttri.contact));
 
% close file
netcdf.close(ncID);

end