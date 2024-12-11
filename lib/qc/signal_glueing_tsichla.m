function [sigGlued] = pollySignalGlueTsichla(signalNR,signalFR,clFreGrps)

% Check the current Python environment status
currentPyenv = pyenv;

% Load Python environment only if it's not already loaded
if strcmp(currentPyenv.Status, 'NotLoaded')
    pyenv(Version="/pollyhome/Bildermacher2/experimental/venv_picassopy/bin/python3");
end


pyrun("import lib.qc.gluing_functions as glueing");

nGroups = size(clFreGrps, 1);
sigGlued = zeros(nGroups, length(signalFR));  % Preallocate 2D array

%disp(nGroups);
%disp(clFreGrps);
for iGrp = 1:nGroups

    tInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);

    if isempty(signalNR) || isempty(signalFR)
        disp('One or both arrays of signalNR / signalFR are empty.');
        return
    else
        nf_signal = squeeze(sum(signalNR( :, tInd), 2));
        ff_signal = squeeze(sum(signalFR( :, tInd), 2));
    
        glued_signal = pyrun("glued_signal = glueing.signal_gluing_function_for_matlab(nf_signal, ff_signal)", "glued_signal", nf_signal=nf_signal, ff_signal=ff_signal);
    
        sigGlued(iGrp,:) = double(glued_signal);
    end
end
