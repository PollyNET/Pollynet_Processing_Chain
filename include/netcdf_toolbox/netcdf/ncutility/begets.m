function msg = Begets(fcn,nin,a,b,c,d,e,f,g,h,i,j)

% Begets -- Message showing the result of a function.
%  Begets('fcn',nin,a,b,...) creates a message that
%   shows the function 'fcn' with its input and
%   output values.  The number of input arguments
%   is nin.  The argument list a,b,... is organized
%   into nin input values, followed immediately by
%   the output values.  Thus, begets('sqrt', 1, 4, 2)
%   results in the message "sqrt(4) ==> 2".

% Uses: var2str.

% Copyright (C) 1991 Charles R. Denham, ZYDECO.
% All Rights Reserved.

if nargin < 1
   help(mfilename)
   disp(' Some examples:')
   x = (1:4).';
   begets('mean', 1, x, mean(x));
   x = (2:4).^2;
   begets('sqrt', 1, x, sqrt(x));
   x = [1 2; 3 4]; [m, n] = size(x);
   begets('size', 1, x, [m n]);
   begets('size', 1, x, m, n);
   x = [1 2; 2 1]; [v, d] = eig(x);
   begets('eig', 1, x, v, d)
   begets('1/0', 0, inf)
   begets('inf.*0', 0, inf.*0)
   x = abs('hello');
   begets('setstr', 1, x, setstr(x))
   x = 'hello';
   begets('abs', 1, x, abs(x))
   return
end

% FCN(...) Input argument list.

s = '';
s = [fcn];
if nin > 0, s = [s '(']; end
arg = 'a';
for ii = 1:nin;
   s = [s var2str(eval(arg))];
   if ii < nin, s = [s ', ']; end
   arg = setstr(arg + 1);
end
if nin > 0, s = [s ')']; end

% [...] Output argument list.

t = '';
nout = nargin - nin - 2;
if nout > 1, t = ['[']; end
for ii = 1:nout
   t = [t var2str(eval(arg))];
   if ii < nout, t = [t ', ']; end
   arg = setstr(arg + 1);
end
if nout > 1, t = [t ']']; end

% Message.

% u = [t ' = ' s];
u = [s ' ==> ' t];

if nargout > 0, msg = u; else, disp([' ' u]); end
