function [mx] = nanrunmedian(x,N,dim);
%NANRUNMEDIAN   Running median.
%   nanrunmedian(x, N) is the running median of the non-NaN elements in x
%   over N points (N is assumed to be integer and odd. The first and last
%   (N-1)/2 points are returned as real numbers if possible.  
%  
%   nanrunmedian(x, N, DIM) takes the running median along the dimension DIM of x. 
      
if nargin < 2
  help nanrunmedian;
  return
end

if nargin < 3
  dim = 1;
end

N = round(N);
% odd numbers only?
if rem(N,2)==0
  N = N + 1;
end

% Avoid scalar case (i.e. singleton dimension)
sizex = size(x);
if length(sizex) < dim || sizex(dim) == 1
  mx = x;
  return;
end

% Setup permute vector if necessary
if dim > 1
  perm = [dim:length(sizex) 1:dim-1];
  x = permute(x,perm);
end

% Calculate running median (except for first and last rows)
d = (N-1)./2;
mx = x .* nan;

for ii=d+1:sizex(dim)-d
  mx(ii,:) = nanmedian2(x(ii-d:ii+d,:));
end

% try first and last few row elements
for ii = 1:d
  mx(ii,:) = nanmedian2(x(1:d+ii,:));
  mx(end-ii+1,:) = nanmedian2(x(end-d-ii+1:end,:));
end

if dim > 1 
  mx = ipermute(mx,perm);
end
