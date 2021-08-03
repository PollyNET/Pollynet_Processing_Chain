function [laserlogs] = readPollyLaserlogbook(laserlogFile, varargin)
% READPOLLYLASERLOGBOOK Read polly laserlog book file.
% USAGE:
%    [laserlogs] = readPollyLaserlogbook(laserlogFile)
% INPUTS:
%    laserlogFile: char
%       absolute path of the laserlog book file.
% KEYWORDS:
%    flagDeleteData: logical
%        flag to control whether to delete the laserlog book file.
%    pollyType: char
%        polly type.
% OUTPUTS:
%    laserlogs: struct
%        time: datenum array
%        AD: array
%            laser energy (measured inside laser head.) [a.u.]
%        EN: array
%            laser energy (measured inside laser head.) [mJ]
%        counts: array
%            flashlamp used counts.
%        ExtPyro: array
%            raw output energy (ExtPyro). [mJ]
%        Temp1064: array
%            temperature for the PMT at 1064nm channel. [degree celsius]
%        Temp1: array
%            temperature for the transmitting chamber. [degree celsius]
%        Temp2: array
%            temperature for the receiving chamber. [degree celsius]
%        OutsideRH: array
%            RH outside the polly system. [%]
%        OutsideT: array
%            temperature outside the Polly system. [degree celsius]
%        roof: array
%            status to show whether the roof is closed.
%        rain: array
%            status to show whether it is raining.
%        shutter: array
%            status to show whether the shutter is closed.
% EXAMPLE:
% HISTORY:
%    2021-04-10: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'laserlogFile', @ischar);
addParameter(p, 'flagDeleteData', false, @islogical);
addParameter(p, 'pollyType', 'arielle', @ischar);

parse(p, laserlogFile, varargin{:});

laserlogs = struct();

switch lower(p.Results.pollyType)
case {'arielle', 'pollyxt_tjk', 'pollyxt_cyp', 'pollyxt_lacros', 'pollyxt_tropos', 'pollyxt_noa', 'pollyxt_tau', 'pollyxt_fmi', 'pollyxt_uw'}
    laserlogs = readPollyXTLaserlogbook(laserlogFile, p.Results.flagDeleteData);
case {'polly_1st'}
    laserlogs = readPolly1stLaserlogbook(laserlogFile, p.Results.flagDeleteData);
case {'polly_1v2'}
    laserlogs = readPolly1v2Laserlogbook(laserlogFile, p.Results.flagDeleteData);
case {'pollyxt_cge'}
    laserlogs = readPollyXTCGELaserlogbook(laserlogFile, p.Results.flagDeleteData);
case {'pollyxt_dwd'}
    laserlogs = readPollyXTDWDLaserlogbook(laserlogFile, p.Results.flagDeleteData);
case {'pollyxt_ift'}
    laserlogs = readPollyXTIfTLaserlogbook(laserlogFile, p.Results.flagDeleteData);
otherwise
    warning('PICASSO:InvalidInput', 'Unknown polly type %s', p.Results.pollyType);
end

end