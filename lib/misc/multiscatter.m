function data = multiscatter(option, varargin)
% MULTISCATTER perform multiple scatter modeling for lidar system. This 
% program is just a simple wrapper for the c programs from Hogan R. The original 
% programs of the model can be downloaded at http://www.met.rdg.ac.uk/clouds/multiscatter/. 
% Version 1.2.10 is required for the base of the wrapper function.
% USAGE:
%    % Usage 1:
%    data = multiscatter('Userdefined', filename);   % User defined cloud 
%       % parameter file is used. The format of the input file can be 
%       % referred to the examples in /multiscatter-1.2.10/examples
%
%    option: char
%        To control the ability of the function. 
%        ('monodispersed' or 'Userdefined')
%    filename: char
%        the full path of the input file.
%    % Usage 2:
%    data = multiscatter('monodispersed', range, cloudBase, ...
%        cloudExt, cloudRadius, cloudLR, lambda, fov, ...
%        divergence, altitude);   % monodispersed cloud parameters 
%                                 % were assumed.
%
%    option: char
%        To control the ability of the function. 
%        ('monodispersed' or 'Userdefined')
%    range: array
%        range of gate above the ground starting with the nearest gate to 
%        instrument. [m]
%    cloudBase: float
%        height of the cloud base. Default is 1000. [m]
%    cloudExt: float
%        mean extinction coefficient of the cloud layer. 
%        Default is 0.01. [m^{-1}]
%    cloudRadius: float
%        effective mean radius of the cloud droplets. Default is 5. [microns]
%    cloudLR: float
%        cloud mean lidar ratio. Default is 18.8. [Sr]
%    lambda: float
%        the wavelength of the transmitting laser. Default is 532. [nm]
%    fov: float
%        receiver field-of-view, 1/e half-width. Default is 0.5. [mrad]
%    divergence: float
%        transmitter divergence, 1/e half-width. Default is 0.1. [mrad]
%    altitude: float
%        altitude of the instrument. Default is 0. [m]
% OUTPUTS:
%    data: struct
%        range: array
%            apparent range above the ground. [m]
%        cloudExt: array
%            cloud extintion coefficient. [m^{-1}]
%        cloudRadius: array
%            cloud effective mean radius. [microns]
%        att_total: array
%            total attenuated backscatter. [m^{-1}*Sr^{-1}]
%        att_single: array
%            attenuated backscatter with single backscattering. 
%            [m^{-1}*Sr^{-1}]
% HISTORY:
%    2021-06-13: first edition by Zhenping
% .. Authors: - zhenping@tropos.de

if strcmpi(option, 'Userdefined')
    data = multiscatter_model(varargin{1});
    return
end

if strcmpi(option, 'monodispersed')
    cloudBase = 1000;
    cloudExt = 0.01;
    cloudRadius = 5;
    cloudLR = 18.8;
    lambda = 532;
    fov = 0.5;
    divergence = 0.1;
    altitude = 0;

    if length(varargin) == 5
        range = varargin{1};
        cloudBase = varargin{2};
        cloudExt = varargin{3};
        cloudRadius = varargin{4};
        cloudLR = varargin{5};
    elseif length(varargin) == 9
        range = varargin{1};
        cloudBase = varargin{2}; 
        cloudExt = varargin{3}; 
        cloudRadius = varargin{4};
        cloudLR = varargin{5}; 
        lambda = varargin{6}; 
        fov = varargin{7}; 
        divergence = varargin{8}; 
        altitude = varargin{9}; 
    else
        error('Wrong inputs.')
    end

    % set molecular extinction coefficient to 0 
    % (you can set it to other values by yourself)
    molecular = zeros(length(range), 1);

    extinction = zeros(length(range), 1);
    radius = ones(length(range), 1) .* cloudRadius;
    S = ones(length(range), 1) .* cloudLR;

    cloudIndx = find(range >= cloudBase & range < (cloudBase + 1000));

    extinction(cloudIndx) = cloudExt + molecular(cloudIndx);

    filename = tempname;

    fid = fopen(filename,'w');
    fprintf(fid,'%6.0f %14.12f %6.1f %12.8f %12.8f\n', ...
            [length(range) lambda/1e9 altitude divergence/1e3 fov/1e3]');
    fprintf(fid,'%8.2f %12.8f %12.8f %12.8f %12.8f\n', ...
            [range' extinction(:) radius(:)/1e6 S(:) molecular(:)]');
    % % taking into account of asymmetry factor
    %fprintf(fid,'%8.2f %12.8f %12.8f %12.8f %12.8f %f %f %f\n', ...
    %[range' extinction(:) radius(:)/1e6 S(:) molecular(:) ...
    %ones(size(range')) 0.86 * ones(size(range')) zeros(size(range'))]');
    fclose(fid);

    data = multiscatter_model(filename);

    delete(filename);
    return;
end

end