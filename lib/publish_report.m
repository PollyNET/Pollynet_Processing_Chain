function [] = publish_report(report, processInfo)
%publish_report send the processing results to developer.
%   Example:
%       [] = publish_report(report, processInfo)
%   Inputs:
%       report, processInfo
%   Outputs:
%       
%   History:
%       2019-01-15. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

reportStr = char(report);

system(sprintf('%s %s %s %s %s', 'python', 'yzp528172875@gmail.com', 'zhenping@tropos.de', sprintf('[%s] pollynet processing program returned results', tNow()), reportStr));

end