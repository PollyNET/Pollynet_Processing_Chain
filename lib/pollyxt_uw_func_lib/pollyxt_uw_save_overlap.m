function [] = pollyxt_uw_save_overlap(data, config, globalAttri, file)
%pollyxt_uw_save_overlap Save the overlap file.
%   Example:
%       [] = pollyxt_uw_save_overlap(data, overlap532, overlap355, overlap532Defaults, overlap355Defaults, file, config, globalAttri);
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           polly processing configuration. More detailed information can be found in doc/polly_config.md
%       globalAttri: struct
%           overlap532: array
%               calculated overlap for 532 nm far range total channel.
%           overlap355: array
%               calculated overlap for 355 nm far range total channel.
%           overlap532Defaults: array
%               default overlap for 532 nm far range total channel.
%           overlap355Defaults: array
%               default overlap for 355 nm far range total channel.
%       file: char
%           netcdf file to save the overlap parameters.
%       
%   Outputs:
%       
%   History:
%       2018-12-21. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if isempty(data.rawSignal)
    return;
end

height = data.height;

% convert empty array to defaults
overlap355 = globalAttri.overlap355;
overlap532 = globalAttri.overlap532;
overlap355Defaults = globalAttri.overlap355DefaultInterp;
overlap532Defaults = globalAttri.overlap532DefaultInterp;
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
varID_height = netcdf.defVar(ncID, 'height', 'NC_DOUBLE', dimID_height);
varID_overlap532 = netcdf.defVar(ncID, 'overlap532', 'NC_DOUBLE', dimID_height);
varID_overlap355 = netcdf.defVar(ncID, 'overlap355', 'NC_DOUBLE', dimID_height);
varID_overlap532Defaults = netcdf.defVar(ncID, 'overlap532Defaults', 'NC_DOUBLE', dimID_height);
varID_overlap355Defaults = netcdf.defVar(ncID, 'overlap355Defaults', 'NC_DOUBLE', dimID_height);
varID_overlapCalMethod = netcdf.defVar(ncID, 'method', 'NC_SHORT', dimID_method);

% leave define mode
netcdf.endDef(ncID);

% write data to .nc file
netcdf.putVar(ncID, varID_height, height);
netcdf.putVar(ncID, varID_overlap532, overlap532);
netcdf.putVar(ncID, varID_overlap355, overlap355);
netcdf.putVar(ncID, varID_overlap532Defaults, overlap532Defaults);
netcdf.putVar(ncID, varID_overlap355Defaults, overlap355Defaults);
netcdf.putVar(ncID, varID_overlapCalMethod, config.overlapCalMode);

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
netcdf.putAtt(ncID, varID_global, 'latitude', data.lat);
netcdf.putAtt(ncID, varID_global, 'longtitude', data.lon);
netcdf.putAtt(ncID, varID_global, 'elev', data.alt0);
netcdf.putAtt(ncID, varID_global, 'location', globalAttri.location);
netcdf.putAtt(ncID, varID_global, 'institute', globalAttri.institute);
netcdf.putAtt(ncID, varID_global, 'version', globalAttri.version);
netcdf.putAtt(ncID, varID_global, 'contact', sprintf('%s', globalAttri.contact));
 
% close file
netcdf.close(ncID);

end