function [chTagsO, chLabels, flagFarRangeChannelO, flagNearRangeChannelO, flagRotRamanChannelO, flagTotalChannelO, flagCrossChannelO, flagParallelChannelO, flag355nmChannelO, flag387nmChannelO, flag407nmChannelO, flag532nmChannelO, flag607nmChannelO, flag1064nmChannelO] = pollyChannelTags(chTagsI, varargin)
% POLLYCHANNELTAGS specify channel tags and labels according to logical settings.
% USAGE:
%    [chTagsO, chLabels, flagFarRangeChannelO, flagNearRangeChannelO, flagRotRamanChannelO, flagTotalChannelO, flagCrossChannelO, flagParallelChannelO, flag355nmChannelO, flag387nmChannelO, flag407nmChannelO, flag532nmChannelO, flag607nmChannelO, flag1064nmChannelO] = pollyChannelTags(chTagsI)
% INPUTS:
%    chTagsI: numeric array
%        manual specified channel tag for each channel. (default: [])
%        73: far-range total 355 nm
%        74: near-range 355 nm
%        81: far-range cross 355 nm
%        129: far-range 387 nm
%        130: near-range 387 nm
%        257: far-range 407 nm
%        517: far-range rotational Raman 532 nm
%        521: far-range total 532 nm
%        522: near-range 532 nm
%        529: far-range cross 532 nm
%        545: far-range parallel 532 nm
%        1025: far-range 607 nm
%        2057: far-range total 1064 nm
%        1026: near-range 607 nm
%        2053: far-range rotational Raman 1064 nm
% KEYWORDS:
%    flagFarRangeChannel: logical
%    flagNearRangeChannel: logical
%    flag532nmChannel: logical
%    flagRotRamanChannel: logical
%    flag355nmChannel: logical
%    flag1064nmChannel: logical
%    flagTotalChannel: logical
%    flagCrossChannel: logical
%    flagParallelChannel: logical
%    flag387nmChannel: logical
%    flag407nmChannel: logical
%    flag607nmChannel: logical
% OUTPUTS:
%    chTagsO: numeric array
%        channel tag.
%    chLabels: cell
%        channel label.
%    flagFarRangeChannelO: logical
%    flagNearRangeChannelO: logical
%    flag532nmChannelO: logical
%    flagRotRamanChannelO: logical
%    flag355nmChannelO: logical
%    flag1064nmChannelO: logical
%    flagTotalChannelO: logical
%    flagCrossChannelO: logical
%    flagParallelChannelO: logical
%    flag387nmChannelO: logical
%    flag407nmChannelO: logical
%    flag607nmChannelO: logical
% EXAMPLE:
% HISTORY:
%    2021-04-23: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'chTagsI');
addParameter(p, 'flagFarRangeChannel', false, @islogical);
addParameter(p, 'flagNearRangeChannel', false, @islogical);
addParameter(p, 'flagRotRamanChannel', false, @islogical);
addParameter(p, 'flagTotalChannel', false, @islogical);
addParameter(p, 'flagCrossChannel', false, @islogical);
addParameter(p, 'flagParallelChannel', false, @islogical);
addParameter(p, 'flag355nmChannel', false, @islogical);
addParameter(p, 'flag387nmChannel', false, @islogical);
addParameter(p, 'flag407nmChannel', false, @islogical);
addParameter(p, 'flag532nmChannel', false, @islogical);
addParameter(p, 'flag607nmChannel', false, @islogical);
addParameter(p, 'flag1064nmChannel', false, @islogical);

parse(p, chTagsI, varargin{:});

nChs = length(p.Results.flagFarRangeChannel);   % number of channels
chTagsO = NaN(1, nChs);
chLabels = cell(1, nChs);

for iCh = 1:nChs

    if (~ isempty(chTagsI))
        % channel tag from keyword of 'chTags'
        chTagsO(iCh) = chTagsI(iCh);
    elseif isempty(chTagsI) && (any(p.Results.flagFarRangeChannel | ...
                                      p.Results.flagNearRangeChannel | ...
                                      p.Results.flagRotRamanChannel | ...
                                      p.Results.flagTotalChannel | ...
                                      p.Results.flagCrossChannel | ...
                                      p.Results.flagParallelChannel | ...
                                      p.Results.flag355nmChannel | ...
                                      p.Results.flag387nmChannel | ...
                                      p.Results.flag407nmChannel | ...
                                      p.Results.flag532nmChannel | ...
                                      p.Results.flag607nmChannel | ...
                                      p.Results.flag1064nmChannel))
        % channel tag from logical variables
        chTagsO(iCh) = sum(2.^(0:(12 - 1)) .* [p.Results.flagFarRangeChannel(iCh), ...
        p.Results.flagNearRangeChannel(iCh), p.Results.flagRotRamanChannel(iCh), ...
        p.Results.flagTotalChannel(iCh), p.Results.flagCrossChannel(iCh), ...
        p.Results.flagParallelChannel(iCh), p.Results.flag355nmChannel(iCh), ...
        p.Results.flag387nmChannel(iCh), p.Results.flag407nmChannel(iCh), ...
        p.Results.flag532nmChannel(iCh), p.Results.flag607nmChannel(iCh), ...
        p.Results.flag1064nmChannel(iCh)]);
    else
        error('PICASSO:InvalidInput', 'Incompatile channels in chTags.');
    end

    switch floor(chTagsO(iCh))
    case 73   % far-range total 355 nm
        chLabels{iCh} = 'far-range total 355 nm';
    case 521   % far-range total 532 nm
        chLabels{iCh} = 'far-range total 532 nm';
    case 2057   % far-range total 1064 nm
        chLabels{iCh} = 'far-range total 1064 nm';
    case 129   % far-range 387 nm
        chLabels{iCh} = 'far-range 387 nm';
    case 257   % far-range 407 nm
        chLabels{iCh} = 'far-range 407 nm';
    case 1025   % far-range 607 nm
        chLabels{iCh} = 'far-range 607 nm';
    case 81   % far-range cross 355 nm
        chLabels{iCh} = 'far-range cross 355 nm';
    case 529   % far-range cross 532 nm
        chLabels{iCh} = 'far-range cross 532 nm';
    case 74   % near-range 355 nm
        chLabels{iCh} = 'near-range 355 nm';
    case 522   % near-range 532 nm
        chLabels{iCh} = 'near-range 532 nm';
    case 130   % near-range 387 nm
        chLabels{iCh} = 'near-range 387 nm';
    case 1026   % near-range 607 nm
        chLabels{iCh} = 'near-range 607 nm';
    case 517   % far-range rotational Raman 532 nm
        chLabels{iCh} = 'far-range rot. Raman 532 nm';
    case 2053   % far-range rotational Raman 1064 nm
        chLabels{iCh} = 'far-range rot. Raman 1064 nm';
    case 545   % far-range parallel 532 nm
        chLabels{iCh} = 'far-range parallel 532 nm';
    otherwise
        warning('PICASSO:InvalidInput', 'Unknown channel tags (%d) at channel %d', chTagsO(iCh), iCh);
        chLabels{iCh} = 'Unknown';
    end
end

%% Extract logical variables for all channels
flagFarRangeChannelO = logical(mod(chTagsO, 2));
flagNearRangeChannelO = logical(mod(floor(chTagsO / 2), 2));
flagRotRamanChannelO = logical(mod(floor(chTagsO / 2^2), 2));
flagTotalChannelO = logical(mod(floor(chTagsO / 2^3), 2));
flagCrossChannelO = logical(mod(floor(chTagsO / 2^4), 2));
flagParallelChannelO = logical(mod(floor(chTagsO / 2^5), 2));
flag355nmChannelO = logical(mod(floor(chTagsO / 2^6), 2));
flag387nmChannelO = logical(mod(floor(chTagsO / 2^7), 2));
flag407nmChannelO = logical(mod(floor(chTagsO / 2^8), 2));
flag532nmChannelO = logical(mod(floor(chTagsO / 2^9), 2));
flag607nmChannelO = logical(mod(floor(chTagsO / 2^10), 2));
flag1064nmChannelO = logical(mod(floor(chTagsO / 2^11), 2));

end