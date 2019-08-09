function y = nanmedian(x,dim)
%NANMEDIAN NaN protected median value.
%   NANMEDIAN(X) returns the median treating NaNs as missing values.
%   For vectors, NANMEDIAN(X) is the median value of the non-NaN
%   elements in X.  For matrices, NANMEDIAN(X) is a row vector
%   containing the median value of each column, ignoring NaNs.
%
%   See also NANMEAN, NANSTD, NANMIN, NANMAX, NANSUM.

%   Copyright 1993-2000 The MathWorks, Inc. 
%   $Revision: 2.11 $  $Date: 2000/05/26 18:53:02 $

if nargin > 1  
  ndims = length(size(x));
  if ndims == 2 & dim == 2 
    x = x';
  elseif dim > 2
%    disp('doesn''t work yet!')
    [x,nshift] = shiftdim(x,dim-1);
  end
end
    
    
x = sort(x); % NaNs are forced to the bottom of each column
[m,n] = size(x);


% Replace NaNs with zeros.
nans = isnan(x);
i = find(nans);
x(i) = zeros(size(i));
if min(size(x))==1,
  n = length(x)-sum(nans);
  if n == 0
    y = NaN;
  else
    if rem(n,2)     % n is odd    
      y = x((n+1)/2);
    else            % n is even
      y = (x(n/2) + x(n/2+1))/2;
    end
  end
else
  n = size(x,1)-sum(nans);
  y = zeros(size(n));

  % Odd columns
  odd = find(rem(n,2)==1 & n>0);
  idx =(n(odd)+1)/2 + (odd-1)*m;
  y(odd) = x(idx);

  % Even columns
  even = find(rem(n,2)==0 & n>0);
  idx1 = n(even)/2 + (even-1)*m;
  idx2 = n(even)/2+1 + (even-1)*m;
  y(even) = (x(idx1)+x(idx2))/2;

  % All NaN columns
  i = find(n==0);
  y(i) = i + nan;
end

if nargin > 1  
  if ndims ==2 & dim == 2 
    y = y';
  elseif dim > 2
    y = shiftdim(y,-nshift);
  end
end
