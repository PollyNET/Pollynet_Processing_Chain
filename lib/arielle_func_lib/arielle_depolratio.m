function [voldepol355_klett, pardepol355_klett, pardepolStd355_klett, voldepol355_raman, pardepol355_raman, pardepolStd355_raman, moldepol355, moldepolStd355, flagDefaultMoldepol355, voldepol532_klett, pardepol532_klett, pardepolStd532_klett, voldepol532_raman, pardepol532_raman, pardepolStd532_raman, moldepol532, moldepolStd532, flagDefaultMoldepol532] = arielle_depolratio(data, config)
%arielle_depolratio retrieve volume depolarization ratio and particle depolarization ratio.
%   Example:
%       [voldepol355_klett, pardepol355_klett, pardepolStd355_klett, voldepol355_raman, pardepol355_raman, pardepolStd355_raman, moldepol355, moldepolStd355, flagDefaultMoldepol355, voldepol532_klett, pardepol532_klett, pardepolStd532_klett, voldepol532_raman, pardepol532_raman, pardepolStd532_raman, moldepol532, moldepolStd532, flagDefaultMoldepol532] = arielle_depolratio(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       voldepol355_klett: matrix
%           volume depolarization ratio at 355 nm for each cloud free group with the same smoothing of Klett method. 
%       pardepol355_klett: matrix
%           particle depolarization ratio at 355 nm based on klett-retrieved backscatter coefficient.
%       pardepol355Std_klett: matrix
%           uncertainty of particle depolarization ratio at 355 nm based on klett-retrieved backscatter coefficient.
%       voldepol355_raman: matrix
%           volume depolarization ratio at 355 nm for each cloud free group with the same smoothing of Raman method. 
%       pardepol355_raman: matrix
%           particle depolarization ratio at 355 nm based on klett-retrieved backscatter coefficient.
%       pardepol355Std_raman: matrix
%           uncertainty of particle depolarization ratio at 355 nm based on raman-retrieved backscatter coefficient.
%       moldepol355: array
%           molecular volume depolarization ratio at 355nm. 
%       moldepolStd355: array
%           std of molecular volume depolarization ratio at 355nm. 
%       flagDefaultMoldepol355: logical
%           flag to show whether using the default molecular volume depolarization ratio.
%       voldepol532_klett: matrix
%           volume depolarization ratio at 532 nm for each cloud free group with the same smoothing of Klett method. 
%       pardepol532_klett: matrix
%           particle depolarization ratio at 532 nm based on klett-retrieved backscatter coefficient.
%       pardepol532Std_klett: matrix
%           uncertainty of particle depolarization ratio at 532 nm based on klett-retrieved backscatter coefficient.
%       voldepol532_raman: matrix
%           volume depolarization ratio at 532 nm for each cloud free group with the same smoothing of Raman method. 
%       pardepol532_raman: matrix
%           particle depolarization ratio at 532 nm based on klett-retrieved backscatter coefficient.
%       pardepol532Std_raman: matrix
%           uncertainty of particle depolarization ratio at 532 nm based on raman-retrieved backscatter coefficient.
%       moldepol532: array
%           molecular volume depolarization ratio at 532nm. 
%       moldepolStd532: array
%           std of molecular volume depolarization ratio at 532nm. 
%       flagDefaultMoldepol532: logical
%           flag to show whether using the default molecular volume depolarization ratio.
%   History:
%       2018-12-23. First Edition by Zhenping
%       2019-05-24. Harmonize the smoothing for parDepol_klett and parDepol_raman
%   Contact:
%       zhenping@tropos.de

global defaults

voldepol355_klett = [];
pardepol355_klett = [];
voldepol355_raman = [];
pardepol355_raman = [];
pardepolStd355_klett = [];
pardepolStd355_raman = [];
moldepol355 = [];
moldepolStd355 = [];
flagDefaultMoldepol355 = [];
voldepol532_klett = [];
pardepol532_klett = [];
voldepol532_raman = [];
pardepol532_raman = [];
pardepolStd532_klett = [];
pardepolStd532_raman = [];
moldepol532 = [];
moldepolStd532 = [];
flagDefaultMoldepol532 = [];

if isempty(data.rawSignal)
    return;
end

%% 355 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisVoldepol355_klett = NaN(size(data.height));
    thisVoldepol355_raman = NaN(size(data.height));
    thisPardepol355_klett = NaN(size(data.height));
    thisPardepol355_raman = NaN(size(data.height));
    thisPardepolStd355_klett = NaN(size(data.height));
    thisPardepolStd355_raman = NaN(size(data.height));
    thisMoldepol355 = NaN;
    thisMoldepolStd355 = NaN;
    thisFlagDefaultMoldepol355 = false;

    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    flagChannel355Tot = config.isFR & config.is355nm & config.isTot;
    flagChannel355Cro = config.isFR & config.is355nm & config.isCross;
    sig355Tot = squeeze(sum(data.signal(flagChannel355Tot, :, proIndx), 3));
    bg355Tot = squeeze(sum(data.bg(flagChannel355Tot, :, proIndx), 3));
    sig355Cro = squeeze(sum(data.signal(flagChannel355Cro, :, proIndx), 3));
    bg355Cro = squeeze(sum(data.bg(flagChannel355Cro, :, proIndx), 3));

    % calculate the volume depolarization ratio
    [thisVoldepol355_klett, thisVoldepoStdl355_klett] = polly_volDepol(sig355Tot, bg355Tot, sig355Cro, bg355Cro, config.TR(flagChannel355Tot), 0, config.TR(flagChannel355Cro), 0, data.depol_cal_fac_355, data.depol_cal_fac_std_355, config.smoothWin_klett_355);
    [thisVoldepol355_raman, thisVoldepoStdl355_raman] = polly_volDepol(sig355Tot, bg355Tot, sig355Cro, bg355Cro, config.TR(flagChannel355Tot), 0, config.TR(flagChannel355Cro), 0, data.depol_cal_fac_355, data.depol_cal_fac_std_355, config.smoothWin_raman_355);

    if ~ isnan(data.refHIndx355(iGroup, 1))

        % calculate the particle depolarization ratio
        if ~ isnan(data.aerBsc355_klett(iGroup, 80))
            [molBsc355, ~] = rayleigh_scattering(355, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

            refHIndx355 = data.refHIndx355(iGroup, 1):data.refHIndx355(iGroup, 2);

            fprintf('Calibrate the molecule depol.ratio for the %d cloud free period at 355 nm.\n', iGroup);
            [thisMoldepol355, thisMoldepolStd355, thisFlagDefaultMoldepol355] = polly_molDepol(sig355Tot(refHIndx355), bg355Tot(refHIndx355), sig355Cro(refHIndx355), bg355Cro(refHIndx355), config.TR(flagChannel355Tot), 0, config.TR(flagChannel355Cro), 0, data.depol_cal_fac_355, data.depol_cal_fac_std_355, 10, defaults.molDepol355, defaults.molDepolStd355);

            % based with klett retrieved bsc
            [thisPardepol355_klett, thisPardepolStd355_klett] = polly_parDepol(thisVoldepol355_klett, thisVoldepoStdl355_klett, data.aerBsc355_klett(iGroup, :), ones(size(data.aerBsc355_klett(iGroup, :))) * 1e-7, molBsc355, thisMoldepol355, thisMoldepolStd355);

            % based with raman retrieved bsc
            if ~ isnan(data.aerBsc355_raman(iGroup, 80))
                [thisPardepol355_raman, thisPardepolStd355_raman] = polly_parDepol(thisVoldepol355_raman, thisVoldepoStdl355_raman, data.aerBsc355_raman(iGroup, :), ones(size(data.aerBsc355_raman(iGroup, :))) * 1e-7, molBsc355, thisMoldepol355, thisMoldepolStd355);
            end
        end
    end
    voldepol355_klett = cat(1, voldepol355_klett, thisVoldepol355_klett);
    voldepol355_raman = cat(1, voldepol355_raman, thisVoldepol355_raman);
    pardepol355_klett = cat(1, pardepol355_klett, thisPardepol355_klett);
    pardepol355_raman = cat(1, pardepol355_raman, thisPardepol355_raman);
    pardepolStd355_klett = cat(1, pardepolStd355_klett, thisPardepolStd355_klett);
    pardepolStd355_raman = cat(1, pardepolStd355_raman, thisPardepolStd355_raman);
    moldepol355 = cat(1, moldepol355, thisMoldepol355);
    moldepolStd355 = cat(1, moldepolStd355, thisMoldepolStd355);
    flagDefaultMoldepol355 = cat(1, flagDefaultMoldepol355, thisFlagDefaultMoldepol355);
end

%% 532 nm
for iGroup = 1:size(data.cloudFreeGroups, 1)
    thisVoldepol532_klett = NaN(size(data.height));
    thisVoldepol532_raman = NaN(size(data.height));
    thisPardepol532_klett = NaN(size(data.height));
    thisPardepol532_raman = NaN(size(data.height));
    thisPardepolStd532_klett = NaN(size(data.height));
    thisPardepolStd532_raman = NaN(size(data.height));
    thisMoldepol532 = NaN;
    thisMoldepolStd532 = NaN;
    thisFlagDefaultMoldepol532 = false;

    proIndx = data.cloudFreeGroups(iGroup, 1):data.cloudFreeGroups(iGroup, 2);
    flagChannel532Tot = config.isFR & config.is532nm & config.isTot;
    flagChannel532Cro = config.isFR & config.is532nm & config.isCross;
    sig532Tot = squeeze(sum(data.signal(flagChannel532Tot, :, proIndx), 3));
    bg532Tot = squeeze(sum(data.bg(flagChannel532Tot, :, proIndx), 3));
    sig532Cro = squeeze(sum(data.signal(flagChannel532Cro, :, proIndx), 3));
    bg532Cro = squeeze(sum(data.bg(flagChannel532Cro, :, proIndx), 3));

    % calculate the volume depolarization ratio
    [thisVoldepol532_klett, thisVoldepoStdl532_klett] = polly_volDepol(sig532Tot, bg532Tot, sig532Cro, bg532Cro, config.TR(flagChannel532Tot), 0, config.TR(flagChannel532Cro), 0, data.depol_cal_fac_532, data.depol_cal_fac_std_532, config.smoothWin_klett_532);
    [thisVoldepol532_raman, thisVoldepoStdl532_raman] = polly_volDepol(sig532Tot, bg532Tot, sig532Cro, bg532Cro, config.TR(flagChannel532Tot), 0, config.TR(flagChannel532Cro), 0, data.depol_cal_fac_532, data.depol_cal_fac_std_532, config.smoothWin_raman_532);

    if ~ isnan(data.refHIndx532(iGroup, 1))

        % calculate the particle depolarization ratio
        if ~ isnan(data.aerBsc532_klett(iGroup, 80))
            [molBsc532, ~] = rayleigh_scattering(532, data.pressure(iGroup, :), data.temperature(iGroup, :) + 273.17, 380, 70);

            refHIndx532 = data.refHIndx532(iGroup, 1):data.refHIndx532(iGroup, 2);

            fprintf('Calibrate the molecule depol.ratio for the %d cloud free period at 532 nm.\n', iGroup);
            [thisMoldepol532, thisMoldepolStd532, thisFlagDefaultMoldepol532] = polly_molDepol(sig532Tot(refHIndx532), bg532Tot(refHIndx532), sig532Cro(refHIndx532), bg532Cro(refHIndx532), config.TR(flagChannel532Tot), 0, config.TR(flagChannel532Cro), 0, data.depol_cal_fac_532, data.depol_cal_fac_std_532, 10, defaults.molDepol532, defaults.molDepolStd532);

            % based with klett retrieved bsc
            [thisPardepol532_klett, thisPardepolStd532_klett] = polly_parDepol(thisVoldepol532_klett, thisVoldepoStdl532_klett, data.aerBsc532_klett(iGroup, :), ones(size(data.aerBsc532_klett(iGroup, :))) * 1e-7, molBsc532, thisMoldepol532, thisMoldepolStd532);

            % based with raman retrieved bsc
            if ~ isnan(data.aerBsc532_raman(iGroup, 80))
                [thisPardepol532_raman, thisPardepolStd532_raman] = polly_parDepol(thisVoldepol532_raman, thisVoldepoStdl532_raman, data.aerBsc532_raman(iGroup, :), ones(size(data.aerBsc532_raman(iGroup, :))) * 1e-7, molBsc532, thisMoldepol532, thisMoldepolStd532);
            end
        end
    end
    voldepol532_klett = cat(1, voldepol532_klett, thisVoldepol532_klett);
    voldepol532_raman = cat(1, voldepol532_raman, thisVoldepol532_raman);
    pardepol532_klett = cat(1, pardepol532_klett, thisPardepol532_klett);
    pardepol532_raman = cat(1, pardepol532_raman, thisPardepol532_raman);
    pardepolStd532_klett = cat(1, pardepolStd532_klett, thisPardepolStd532_klett);
    pardepolStd532_raman = cat(1, pardepolStd532_raman, thisPardepolStd532_raman);
    moldepol532 = cat(1, moldepol532, thisMoldepol532);
    moldepolStd532 = cat(1, moldepolStd532, thisMoldepolStd532);
    flagDefaultMoldepol532 = cat(1, flagDefaultMoldepol532, thisFlagDefaultMoldepol532);
end

end