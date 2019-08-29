function [ang_ext_355_532_raman, ang_bsc_355_532_raman, ang_bsc_532_1064_raman, ang_bsc_355_532_klett, ang_bsc_532_1064_klett] = pollyxt_fmi_angstrexp(data, config)
%pollyxt_fmi_angstrexp Retrieve the angstroem exponent with klett-retrieve and raman-retrieved aerosol optical properties.
%   Example:
%       [ang_ext_355_532_raman, ang_bsc_355_532_raman, ang_bsc_532_1064_raman, ang_bsc_355_532_klett, ang_bsc_532_1064_klett] = pollyxt_fmi_angstrexp(data, config)
%   Inputs:
%       data.struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       ang_ext_355_532_raman: matrix
%           angstroem exponent.
%       ang_bsc_355_532_raman: matrix
%           angstroem exponent.
%       ang_bsc_532_1064_raman: matrix
%           angstroem exponent.
%       ang_bsc_355_532_klett: matrix
%           angstroem exponent.
%       ang_bsc_532_1064_klett: matrix
%           angstroem exponent.
%   History:
%       2018-12-24. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

ang_ext_355_532_raman = [];
ang_bsc_355_532_raman = [];
ang_bsc_532_1064_raman = [];
ang_bsc_355_532_klett = [];
ang_bsc_532_1064_klett = [];

if isempty(data.rawSignal)
    return;
end

for iGroup = 1:size(data.cloudFreeGroups, 1)
    this_ang_ext_355_532_raman = NaN(size(data.height));
    this_ang_bsc_355_532_raman = NaN(size(data.height));
    this_ang_bsc_532_1064_raman = NaN(size(data.height));
    this_ang_bsc_355_532_klett = NaN(size(data.height));
    this_ang_bsc_532_1064_klett = NaN(size(data.height));
    aerExtStd355_raman = zeros(size(data.height));
    aerExtStd532_raman = zeros(size(data.height));
    aerBscStd355_raman = zeros(size(data.height));
    aerBscStd532_raman = zeros(size(data.height));
    aerBscStd1064_raman = zeros(size(data.height));
    aerBscStd355_klett = zeros(size(data.height));
    aerBscStd532_klett = zeros(size(data.height));
    aerBscStd1064_klett = zeros(size(data.height));

    if (~ isnan(data.aerExt355_raman(iGroup, 80))) && (~ isnan(data.aerExt532_raman(iGroup, 80)))
        [this_ang_ext_355_532_raman, ~] = polly_angexp(data.aerExt355_raman(iGroup, :), aerExtStd355_raman, data.aerExt532_raman(iGroup, :), aerExtStd532_raman, 355, 532, config.smoothWin_raman_532);
    end

    if (~ isnan(data.aerBsc355_raman(iGroup, 80))) && (~ isnan(data.aerBsc532_raman(iGroup, 80)))
        [this_ang_bsc_355_532_raman, ~] = polly_angexp(data.aerBsc355_raman(iGroup, :), aerBscStd355_raman, data.aerBsc532_raman(iGroup, :), aerBscStd532_raman, 355, 532, config.smoothWin_raman_532);
    end

    if (~ isnan(data.aerBsc532_raman(iGroup, 80))) && (~ isnan(data.aerBsc1064_raman(iGroup, 80)))
        [this_ang_bsc_532_1064_raman, ~] = polly_angexp(data.aerBsc532_raman(iGroup, :), aerBscStd532_raman, data.aerBsc1064_raman(iGroup, :), aerBscStd1064_raman, 532, 1064, config.smoothWin_raman_1064);
    end

    if (~ isnan(data.aerBsc355_klett(iGroup, 80))) && (~ isnan(data.aerBsc532_klett(iGroup, 80)))
        [this_ang_bsc_355_532_klett, ~] = polly_angexp(data.aerBsc355_klett(iGroup, :), aerBscStd355_klett, data.aerBsc532_klett(iGroup, :), aerBscStd532_klett, 355, 532, config.smoothWin_klett_532);
    end

    if (~ isnan(data.aerBsc532_klett(iGroup, 80))) && (~ isnan(data.aerBsc1064_klett(iGroup, 80)))
        [this_ang_bsc_532_1064_klett, ~] = polly_angexp(data.aerBsc532_klett(iGroup, :), aerBscStd532_klett, data.aerBsc1064_klett(iGroup, :), aerBscStd1064_klett, 532, 1064, config.smoothWin_klett_1064);
    end

    ang_ext_355_532_raman = cat(1, ang_ext_355_532_raman, this_ang_ext_355_532_raman);
    ang_bsc_355_532_raman = cat(1, ang_bsc_355_532_raman, this_ang_bsc_355_532_raman);
    ang_bsc_532_1064_raman = cat(1, ang_bsc_532_1064_raman, this_ang_bsc_532_1064_raman);
    ang_bsc_355_532_klett = cat(1, ang_bsc_355_532_klett, this_ang_bsc_355_532_klett);
    ang_bsc_532_1064_klett = cat(1, ang_bsc_532_1064_klett, this_ang_bsc_532_1064_klett);
end

end