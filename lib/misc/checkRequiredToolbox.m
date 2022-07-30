function [flag, missedToolboxes] = checkRequiredToolbox(varargin)
% CHECKREQUIREDTOOLBOX check whether required toolboxes for running pollynet processing chain are all available.
%
% USAGE:
%    [flag, missedToolboxes] = checkRequiredToolbox()
%
% INPUTS:
%
% OUTPUTS:
%    flag: logical
%        determine whether all required Matlab toolboxes were activated.
%    missedToolboxes: cell
%        list toolboxes that were not activated.
%
% HISTORY:
%    2022-07-29: first edition by Zhenping
% .. Authors: - zp.yin@whu.edu.cn

requiredToolboxes = {'curve_fitting_toolbox', ...
                     'database_toolbox', ...
                     'symbolic_math_toolbox'};

%% Check required toolboxes
missedToolboxes = cell(0);
for iRow = 1:length(requiredToolboxes)
    if ~ license('test', requiredToolboxes{iRow})
        missedToolboxes = cat(2, missedToolboxes, requiredToolboxes{iRow});
    end
end

flag = false;
if isempty(missedToolboxes)
    flag = true;
end

end