function [volDepol] = polly_volDepol2(sigTot, sigCross, Rt, Rc, depolConst)
%POLLY_VOLDEPOL2 calculate the 2-dimensional volume depolarization ratio for pollyXT system.
%	Example:
%		[volDepol] = polly_volDepol2(sigTot, sigCross, Rt, Rc, depolConst)
%	Inputs:
%		sigTot: array
%			signal strength of the total channel. [photon count]
%		sigCross: array
%			signal strength of the cross channel. [photon count]
%		Rt: scalar
%			transmission ratio in total channel
%		Rc: scalar
%			transmission ratio in cross channel
%		depolConst: scalar
%			depolarzation calibration constant. (transmission ratio for the 
%			parallel component in cross channel and total channel)
%	Outputs:
%		volDepol: array
%			volume depolarization ratio.
% 	Reference:
%		instrumentation info about PollyXT can be found in 
%		(R.Engelmann et al, AMT, 2016) and deduction about volume 
%		depolarization calculation can be found in (Freudenthaler et al,
%		Tellus B, 2009)
%	History:
%       2018-12-24. First edition by Zhenping
%	Contact:
%		zhenping@tropos.de

sigRatio = sigCross./sigTot;
volDepol = (1 - sigRatio ./ depolConst) ./ (sigRatio * Rt / depolConst - Rc);

end