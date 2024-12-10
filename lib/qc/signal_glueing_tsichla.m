function [sigGlued] = pollySignalGlueTsichla(signalNR,signalFR,clFreGrps)
pyenv(Version="/pollyhome/Bildermacher2/experimental/venv_picassopy/bin/python3");

pyrun("import lib.qc.gluing_functions as glueing");

%% whos signalNR;
%% whos signalFR;

nGroups = size(clFreGrps, 1);
sigGlued = zeros(nGroups, length(signalFR));  % Preallocate 2D array

for iGrp = 1:nGroups

    tInd = clFreGrps(iGrp, 1):clFreGrps(iGrp, 2);

    nf_signal = squeeze(sum(signalNR( :, tInd), 2));
    ff_signal = squeeze(sum(signalFR( :, tInd), 2));

%nf_signal = signalNR;
%ff_signal = signalFR;


    glued_signal = pyrun("glued_signal = glueing.signal_gluing_function_for_matlab(nf_signal, ff_signal)", "glued_signal", nf_signal=nf_signal, ff_signal=ff_signal);

    sigGlued(iGrp,:) = double(glued_signal);
end
