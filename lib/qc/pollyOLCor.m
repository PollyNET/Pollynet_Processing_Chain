function [sigOLCor, bgOLCor, olFuncDeft, flagOLDeft] = pollyOLCor(height, sigFR, bgFR, varargin)
% POLLYOLCOR overlap correction.
%
% USAGE:
%    [sigOLCor, bgOLCor, olFuncDeft, flagOLDeft] = pollyOLCor(height, sigFR, bgFR)
%
% INPUTS:
%    height: array
%        height above ground. (m) 
%    sigFR: array
%        far-field channel signal.
%    bgFR: array
%        far-field channel background
%
% KEYWORDS:
%    signalNR: array
%        near-field channel signal
%    bgNR: array
%        near-field channel signal
%    signalRatio: numeric
%        ratio between near-field and far-field signal.
%    normRange: 2-element array
%        normalization range (index) for signal ratio between near-field and far-field signal.
%    defaultOLFile: char
%        absolute path of default overlap file.
%    overlapCorMode: numeric
%        overlap correction mode.
%        0: no overlap correction;
%        1:overlap correction with using the default overlap function.
%        2: overlap correction with using the calculated overlap function.
%        3: overlap correction with gluing near-range and far-range signal.
%    overlapCalMode: numeric
%        overlap calculation method.
%       1: signal ratio of near and far range signal.
%       2: Raman method (Wandinger and Ansmann 2002)'.

%    overlapSmWin: numeric
%        smoothing window for overlap function (in bins)
%    overlap: array
%        overlap function.
%    overlap_Raman: array
%        overlap function Raman method.
%
% OUTPUTS:
%    sigOLCor: array
%        overlap corrected signal.
%    bgOLCor: array
%        overlap corrected background.
%    olFuncDeft
%        default overlap function.
%    flagOLDeft
%        flag to determine whether default overlap function was applied in the overlap correction.
%
% HISTORY:
%    - 2021-05-22: first edition by Zhenping
%    - 2023-09-29: editon by Cristofer. Case 4 added (Raman method)
%
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'height', @isnumeric);
addRequired(p, 'sigFR', @isnumeric);
addRequired(p, 'bgFR', @isnumeric);
addParameter(p, 'signalNR', [], @isnumeric);
addParameter(p, 'bgNR', [], @isnumeric);
addParameter(p, 'signalRatio', [], @isnumeric);
addParameter(p, 'normRange', [], @isnumeric);
addParameter(p, 'defaultOLFile', '', @ischar);
addParameter(p, 'overlapCorMode', 0, @isnumeric);
addParameter(p, 'overlapCalMode', 0, @isnumeric);
addParameter(p, 'overlapSmWin', 3, @isnumeric);
addParameter(p, 'overlap', [], @isnumeric);
addParameter(p, 'overlap_Raman', [], @isnumeric);

parse(p, height, sigFR, bgFR, varargin{:});

if p.Results.overlapSmWin <= 3
    error('''overlapSmWin must be larger than 3''');
end

%% read default overlap function
[hDeft, olDeft] = readDefaultOL(p.Results.defaultOLFile);

%% interpolate default overlap to the same grid of lidar data
if ~ isempty(olDeft)
    olFuncDeft = interp1(hDeft, olDeft, height, 'linear');
else
    olFuncDeft = NaN(size(height));
end

%% overlap correction
flagOLDeft = false;
sigOLCor = sigFR;
bgOLCor = bgFR;

switch p.Results.overlapCorMode
    case 0
        % no overlap correction
        sigOLCor = sigFR;
        bgOLCor = bgFR;
        
    case 1
        % overlap correction with default overlap function
        olSm = smooth(olFuncDeft, p.Results.overlapSmWin, 'sgolay', 2);
        sigOLCor = olCor(sigFR, transpose(olSm), height, height(p.Results.normRange));
        bgOLCor = olCor(bgFR, transpose(olSm), height, height(p.Results.normRange));
        
        flagOLDeft = true;
        
    case 2
        
        % overlap correction with the realtime calculated overlap function
        if p.Results.overlapCalMode==1
            %NF/FR method
            if isempty(p.Results.overlap)
                olSm = smooth(olFuncDeft, p.Results.overlapSmWin, 'sgolay', 2);
                flagOLDeft = true;
            else
                olSm = smooth(p.Results.overlap, p.Results.overlapSmWin, 'sgolay', 2);
                flagOLDeft = false;
            end
            
            sigOLCor = olCor(sigFR, transpose(olSm), height, height(p.Results.normRange));
            bgOLCor = olCor(bgFR, transpose(olSm), height, height(p.Results.normRange));
            
        elseif p.Results.overlapCalMode==2
            % Raman method
            
            if isempty(p.Results.overlap_Raman)
                olSm = smooth(olFuncDeft, p.Results.overlapSmWin, 'sgolay', 2);
                flagOLDeft = true;
                sigOLCor = olCor(sigFR, transpose(olSm), height, height(p.Results.normRange));
                bgOLCor = olCor(bgFR, transpose(olSm), height, height(p.Results.normRange));
            else
                flagOLDeft = false;
                ovl_for_correction=repmat(p.Results.overlap_Raman,[1,size(sigFR,2)]);
                sigOLCor = sigFR ./ ovl_for_correction;
                bgOLCor = bgFR./ ovl_for_correction;
            end
        end
        
        
        
    case 3
        % signal glue
        if (~ isempty(p.Results.signalNR)) && (length(p.Results.signalNR) == length(sigFR))
            sigOLCor = sigGlue(sigFR, p.Results.signalNR, p.Results.signalRatio, ...
                height, height(p.Results.normRange));
            bgOLCor = sigGlue(bgFR, p.Results.bgNR, p.Results.signalRatio, height, height(p.Results.normRange));
        end
    case 4
        % signal gluing according to Maria T script
        %call python 
        % 2 function: one for finding glueing region
        % 
    otherwise
        error('Unknown overlap correction mode %d', p.Results.overlapCorMode);
end

end