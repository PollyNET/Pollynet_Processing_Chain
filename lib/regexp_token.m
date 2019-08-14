function [item] = regexp_token(thisStr, pattern, defaults)
%REGEXP_TOKEN regexp with the input pattern. If not found, return defaults. (Use 
%only 1 output token in the 'pattern')
%   Example:
%       [item] = regexp_token(thisStr, pattern, defaults)
%   Inputs:
%       thisStr: char
%           input char array.
%           e.g., 'a: 2; b: 3' 
%       pattern: char
%           search patter. (Defailed information can be found in REGEXP)
%           e.g., '(?<=b: )\d*' 
%       defaults: char
%           default return for the searched patter.
%   Outputs:
%       item: char
%           the searched pattern.
%           e.g., '3'
%   History:
%       2019-08-04. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist('defaults', 'var')
    defaults = '';
end

subStr = regexp(thisStr, pattern, 'match');
if isempty(subStr)
    item = defaults;
else
    item = subStr{1};
end

end