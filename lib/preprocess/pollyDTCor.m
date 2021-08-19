function [sigO] = pollyDTCor(sigI, mShots, hRes, varargin)
% POLLYDTCOR deadtime correction for polly photon counting data.
%
% USAGE:
%    [sigO] = pollyDTCor(sigI, mShots, hRes, varargin)
%
% INPUTS:
%    sigI: matrix (channel x height x time)
%        raw photon counting signal.
%    mShots: matrix (channel x time)
%        number of accumulated shots for each profile.
%    hRes: numeric
%        height resolution. (m)
%
% KEYWORDS:
%    pollyType: char
%        polly version. (default: 'arielle')
%    flagDeadTimeCorrection: logical
%        flag to control whether to apply deadtime correction. (default: false)
%    deadtimeCorrectionMode: numeric
%        deadtime correction mode. (default: 2)
%        1: polynomial correction with parameters saved in data file.
%        2: non-paralyzable correction
%        3: polynomail correction with user defined parameters
%        4: disable deadtime correction
%    deadtimeParams: numeric
%        deadtime parameters. (default: [])
%    deadtime: matrix (channel x polynomial_orders)
%        deadtime correction parameters.
%
% OUTPUTS:
%    sigO: matrix (channel x height x time)
%       deadtime corrected signal in photon count.
%
% HISTORY:
%    - 2021-05-16: first edition by Zhenping
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'sigI', @isnumeric);
addRequired(p, 'mShots', @isnumeric);
addRequired(p, 'hRes', @isnumeric);
addParameter(p, 'flagDeadTimeCorrection', false, @islogical);
addParameter(p, 'deadtimeCorrectionMode', 4, @isnumeric);
addParameter(p, 'deadtime', [], @isnumeric);
addParameter(p, 'deadtimeParams', [], @isnumeric);
addParameter(p, 'pollyType', 'polly', @ischar);

parse(p, sigI, mShots, hRes, varargin{:});

sigO = sigI;
MShots = repmat(...
    reshape(mShots, size(mShots, 1), 1, size(mShots, 2)), ...
    [1, size(sigI, 2), 1]);   % reshape mShots to the same dimensions of sigI

%% Deadtime correction
if p.Results.flagDeadTimeCorrection
    PCR = sigI ./ MShots * 150.0 ./ hRes;   % convert photon counts to phton 
                                            % count rate [MHz]

    % polynomial correction with parameters saved in netcdf file
    if p.Results.deadtimeCorrectionMode == 1
        for iCh = 1:size(sigI, 1)
            PCR_Cor = polyval(p.Results.deadtime(iCh, end:-1:1), ...
                              PCR(iCh, :, :));
            sigO(iCh, :, :) = PCR_Cor / (150.0 / hRes) .* MShots(iCh, :, :);
        end

    % nonparalyzable correction
    elseif p.Results.deadtimeCorrectionMode == 2
        for iCh = 1:size(sigI, 1)
            PCR_Cor = PCR(iCh, :, :) ./ ...
                      (1.0 - p.Results.deadtimeParams(iCh) * 1e-3 * ...
                      PCR(iCh, :, :));
            sigO(iCh, :, :) = PCR_Cor / (150.0 / hRes) .* MShots(iCh, :, :);
        end

    % user defined deadtime.
    % Regarding the format of deadtime, please go to /doc/polly_config.md
    elseif p.Results.deadtimeCorrectionMode == 3
        if ~ isempty(p.Results.deadtimeParams)
            for iCh = 1:size(sigI, 1)
                PCR_Cor = polyval(p.Results.deadtimeParams(iCh, end:-1:1), ...
                                  PCR(iCh, :, :));
                sigO(iCh, :, :) = PCR_Cor / (150.0 / hRes) .* MShots(iCh, :, :);
            end
        else
            warning(['User defined deadtime parameters were not found. ', ...
                     'Please go back to check the configuration ', ...
                     'file for %s.'], p.Results.pollyType);
            warning(['In order to continue the current processing, ', ...
                     'deadtime correction will not be implemented. ', ...
                     'Be careful!']);
        end

    % No deadtime correction
    elseif p.Results.deadtimeCorrectionMode == 4
        fprintf(['Deadtime correction was turned off. ', ...
                 'Be careful to check the signal strength.\n']);
    else
        error(['Unknow deadtime correction setting! ', ...
               'Please go back to check the configuration ', ...
               'file for %s. For deadtimeCorrectionMode, only 1-4 is allowed.'], ...
               p.Results.pollyType);
    end
end