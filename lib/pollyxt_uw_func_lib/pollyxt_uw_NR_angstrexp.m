function [ang_ext_355_532_raman, ang_bsc_355_532_raman, ang_bsc_355_532_klett] = pollyxt_uw_NR_angstrexp(data, config)
%pollyxt_uw_NR_angstrexp Retrieve the angstroem exponent with klett-retrieve and raman-retrieved aerosol optical properties.
%   Example:
%       [ang_ext_355_532_raman, ang_bsc_355_532_raman, ang_bsc_355_532_klett] = pollyxt_uw_NR_angstrexp(data, config)
%   Inputs:
%		data: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%       config: struct
%           More detailed information can be found in doc/pollynet_processing_program.md
%   Outputs:
%       ang_ext_355_532_raman: matrix
%           angstroem exponent.
%       ang_bsc_355_532_raman: matrix
%           angstroem exponent.
%       ang_bsc_355_532_klett: matrix
%           angstroem exponent.
%   History:
%       2019-08-06. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

ang_ext_355_532_raman = [];
ang_bsc_355_532_raman = [];
ang_bsc_355_532_klett = [];

if isempty(data.rawSignal)
    return;
end

for iGroup = 1:size(data.cloudFreeGroups, 1)
    this_ang_ext_355_532_raman = NaN(size(data.height));
    this_ang_bsc_355_532_raman = NaN(size(data.height));
    this_ang_bsc_355_532_klett = NaN(size(data.height));
    aerExtStd355_NR_raman = zeros(size(data.height));
    aerExtStd532_NR_raman = zeros(size(data.height));
    aerBscStd355_NR_raman = zeros(size(data.height));
    aerBscStd532_NR_raman = zeros(size(data.height));
    aerBscStd355_NR_klett = zeros(size(data.height));
    aerBscStd532_NR_klett = zeros(size(data.height));

    if (~ isnan(data.aerExt355_NR_raman(iGroup, 60))) && (~ isnan(data.aerExt532_NR_raman(iGroup, 60)))
        [this_ang_ext_355_532_raman, ~] = polly_angexp(data.aerExt355_NR_raman(iGroup, :), aerExtStd355_NR_raman, data.aerExt532_NR_raman(iGroup, :), aerExtStd532_NR_raman, 355, 532, config.smoothWin_raman_NR_355);
    end

    if (~ isnan(data.aerBsc355_NR_raman(iGroup, 60))) && (~ isnan(data.aerBsc532_NR_raman(iGroup, 60)))
        [this_ang_bsc_355_532_raman, ~] = polly_angexp(data.aerBsc355_NR_raman(iGroup, :), aerBscStd355_NR_raman, data.aerBsc532_NR_raman(iGroup, :), aerBscStd532_NR_raman, 355, 532, config.smoothWin_raman_NR_532);
    end

    if (~ isnan(data.aerBsc355_NR_klett(iGroup, 60))) && (~ isnan(data.aerBsc532_NR_klett(iGroup, 60)))
        [this_ang_bsc_355_532_klett, ~] = polly_angexp(data.aerBsc355_NR_klett(iGroup, :), aerBscStd355_NR_klett, data.aerBsc532_NR_klett(iGroup, :), aerBscStd532_NR_klett, 355, 532, config.smoothWin_klett_NR_532);
    end

    ang_ext_355_532_raman = cat(1, ang_ext_355_532_raman, this_ang_ext_355_532_raman);
    ang_bsc_355_532_raman = cat(1, ang_bsc_355_532_raman, this_ang_bsc_355_532_raman);
    ang_bsc_355_532_klett = cat(1, ang_bsc_355_532_klett, this_ang_bsc_355_532_klett);
end

end