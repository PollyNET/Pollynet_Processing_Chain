% """
% Basic physics constants used in all submodules.
% 
% Values taken from http://physics.nist.gov/cuu/Constants/index.html (2014 values)
% """
function [const] = physical_constants()
const.constantsh = 6.626070040e-34;  % plank constant in J s
const.c = 299792458.;  % speed of light in m s-1
const.k_b = 1.38064852 * 10^-23;  % Boltzmann constant in J/K
% k_b = 1.3806504 * 10**-23  # J/K  - Folker value

% Molar gas constant
%R = 8.3144598  # in J/mol/K --
const.R = 8.314510;  % Value in Ciddor 1996.