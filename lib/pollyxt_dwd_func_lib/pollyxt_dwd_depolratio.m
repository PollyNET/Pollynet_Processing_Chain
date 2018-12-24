function [voldepol532, pardepol532_klett, pardepol532_raman, moldepol532, moldepolStd532, flagDefaultMoldepol532] = pollyxt_dwd_depolratio(data, config)
%pollyxt_dwd_depolratio retrieve volume depolarization ratio and particle depolarization ratio.
%   Example:
%       [voldepol532, pardepol532_klett, pardepol532_raman, moldepol532, moldepolStd532, flagDefaultMoldepol532] = pollyxt_dwd_depolratio(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       voldepol532: matrix
%           volume depolarization ratio at 532 nm for each cloud free group. 
%       pardepol532_klett: matrix
%           particle depolarization ratio at 532 nm based on klett-retrieved backscatter coefficient.
%       pardepol532_raman: matrix
%           particle depolarization ratio at 532 nm based on klett-retrieved backscatter coefficient.
%       moldepol532: array
%           molecular volume depolarization ratio at 532nm. 
%       moldepolStd532: array
%           std of molecular volume depolarization ratio at 532nm. 
%       flagDefaultMoldepol532: logical
%           flag to show whether using the default molecular volume depolarization ratio.
%   History:
%       2018-12-23. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

global defaults

voldepol532 = [];
pardepol532_klett = [];
pardepol532_raman = [];
moldepol532 = [];
moldepolStd532 = [];
flagDefaultMoldepol532 = [];

if isempty(data.rawSignal)
    return;
end

%% 532 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisVoldepol532 = NaN(size(data.height));
    thisPardepol532_klett = NaN(size(data.height));
    thisPardepol532_raman = NaN(size(data.height));
    thisMoldepol532 = NaN;
    thisMoldepolStd532 = NaN;
    flagDefaultMoldepol532 = false;

    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    flagChannel532Tot = config.isFR & config.is532nm & config.isTot;
    flagChannel532Cro = config.isFR & config.is532nm & config.isCross;

    if ~ isnan(data.refHIndx532(iGroup, 1))
        % TODO calculate voldepol and calibrate the molDepol
        sig532Tot = squeeze(sum(data.signal(flagChannel532Tot, :, proIndx), 3));
        bg532Tot = squeeze(sum(data.bg(flagChannel532Tot, :, proIndx), 3));
        sig532Cro = squeeze(sum(data.signal(flagChannel532Cro, :, proIndx), 3));
        bg532Cro = squeeze(sum(data.bg(flagChannel532Cro, :, proIndx), 3));

        % calculate the volume depolarization ratio
        [thisVoldepol532, thisVoldepoStdl532] = polly_volDepol(sig532Tot, bg532Tot, sig532Cro, bg532Cro, config.TR(flagChannel532Tot), 0, config.TR(flagChannel532Cro), 0, data.depol_cal_fac_532, data.depol_cal_fac_std_532, config.smoothWin_klett_532);

        % calculate the particle depolarization ratio
        if ~ isnan(data.aerBsc532_klett(iGroup, 80))
            [molBsc532, ~] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

            refHIndx532 = data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2);

            [thisMoldepol532, thisMoldepolStd532, thisFlagDefaultMoldepol532] = polly_molDepol(sig532Tot(refHIndx532), bg532Tot(refHIndx532), sig532Cro(refHIndx532), bg532Cro(refHIndx532), data.depol_cal_fac_532, data.depol_cal_fac_std_532, 50, defaults.molDepol532, defaults.molDepolStd532);

            % based with klett retrieved bsc
            [thisPardepol532_klett, ~] = polly_parDepol(thisVoldepol532, thisVoldepoStdl532, data.aerBsc532_klett(iGroup, :), zeros(size(data.aerBsc532_klett(iGroup, :))), molBsc532, molDepol532, molDepolStd532);

            % based with raman retrieved bsc
            if ~ isnan(data.aerBsc532_raman(iGroup, 80))
                [thisPardepol532_raman, ~] = polly_parDepol(thisVoldepol532, thisVoldepoStdl532, data.aerBsc532_raman(iGroup, :), zeros(size(data.aerBsc532_raman(iGroup, :))), molBsc532, thisMoldepol532, thisMoldepolStd532);
            end
        end

        
    voldepol532 = cat(1, voldepol532, thisVoldepol532);
    pardepol532_klett = cat(1, pardepol532_klett, thisPardepol532_klett);
    pardepol532_raman = cat(1, pardepol532_raman, thisPardepol532_raman);
    moldepol532 = cat(1, moldepol532, thisMoldepol532);
    moldepolStd532 = cat(1, moldepolStd532, thisMoldepolStd532);
    flagDefaultMoldepol532 = cat(1, flagDefaultMoldepol532, thisFlagDefaultMoldepol532);
    end
end

end