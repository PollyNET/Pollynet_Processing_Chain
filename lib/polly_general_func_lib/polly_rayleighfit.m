function [refHIndx, dpIndx] = polly_rayleighfit(distance0, sig, sigPCR, bg, ...
    molsig, minDecomLogDist, searchBase, searchTop, maxDecomThickness, ...
    decomSmoothWin, minRefThickness, minRefDeltaExt, minRefSNR)
%POLLY_RAYLEIGHFIT Search the reference height with rayleighfitting algorithm. 
%More detailed information can be found in doc/pollynet_processing_program.md
%   Example:
%       [refHIndx] = polly_rayleighfit(distance0, sig, sigPCR, bg, molsig, 
%       minDecomLogDist, searchBase, searchTop, maxDecomThickness, 
%       decomSmoothWin, minRefThickness, minRefDeltaExt, minRefSNR)
%   Inputs:
%       distance0: array
%           the distance between each range bin to the system. [m] 
%       sig: array
%           signal strength. [photon count]
%       sigPCR: array
%           signal strength. [photon count rate] 
%       bg: array
%           background signal. [photon count] 
%       molsig: array
%           range-corrected rayleigh signal.  
%       minDecomLogDist: float
%           the minumum logarithm distance for Douglas-Peucker decomposition. 
%       searchBase: float
%           the base height for rayleigh fitting. [m] 
%       searchTop: float
%           the top height for rayleigh fitting. [m] 
%       maxDecomThickness: float
%           maximum thickness for each decomposed segement. [m] 
%       decomSmoothWin: integer
%           smoothing window. 
%       minRefThickness: float
%           minimum thickness requirement for reference height. [m] 
%       minRefDeltaExt: float
%           minimum uncertainty of extinction at reference height. 
%       minRefSNR: float
%           minimum integral SNR at reference height.
%   Outputs:
%       refHIndx: 2-element array
%           index of reference height. If no reference height was found, NaN 
%           will be returned.
%       dpIndx: array
%           Douglas-Peucker decomposition points.
%   Note:
%       For more information about Douglas-Peucker Decomposition and rayleigh 
%       fitting, please go to doc/pollynet_processing_program.md.
%   History:
%       2018-12-23. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

molCorSig = sigPCR .* distance0.^2 ./ molsig;
dpIndx = DouglasPeucker(molCorSig, distance0, minDecomLogDist, searchBase, ...
                        searchTop, maxDecomThickness, decomSmoothWin);

RCS = sigPCR .* distance0.^2;
[hBIndx, hTIndx] = rayleighfit(distance0, RCS, sig, bg, molsig, dpIndx, ...
                            minRefThickness, minRefDeltaExt, minRefSNR, true);

refHIndx = [hBIndx, hTIndx];

end