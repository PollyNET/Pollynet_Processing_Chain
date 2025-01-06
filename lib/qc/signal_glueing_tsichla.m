function [sigGlued] = pollySignalGlueTsichla(signalNR,signalFR,clFreGrps,pyBinDir)

nGroups = size(clFreGrps, 1);
sigGlued = zeros(nGroups, length(signalFR));  % Preallocate 2D array

%%pyFolder = PicassoConfig.pyBinDir;   % folder of the python scripts for data visualization
pythonPath = fullfile(pyBinDir, 'python3');
%%%pythonPath = '/lacroshome/cloudnetpy/cloudnetpy-env/bin/python3';
%%pythonScript = fullfile(PicassoDir, 'lib', 'visualization', 'pypolly_display_all.py');
%%measurement_date = [datestr(PollyDataInfo.dataTime, 'yyyy'), datestr(PollyDataInfo.dataTime, 'mm'), datestr(PollyDataInfo.dataTime, 'dd')];
%%pypolly_command = sprintf('%s %s --date %s --device %s --picasso_config_file %s --polly_config_file %s --outdir %s --retrieval all --donefilelist true', pythonPath, pythonScript, measurement_date, pollyType, PicassoConfigFile, PollyConfig.pollyConfigFile, PicassoConfig.pic_folder);
%%disp(pypolly_command);
%% [status, output] = system(pypolly_command);
%%system(pypolly_command);

% get matlab.version-realease
matlab_release = regexp(version, 'R\d{4}[ab]', 'match', 'once');

% Check the current Python environment status
currentPyenv = pyenv;

% Load Python environment only if it's not already loaded
if strcmp(currentPyenv.Status, 'NotLoaded')
    %pyenv(Version="/pollyhome/Bildermacher2/experimental/venv_picassopy/bin/python3");
    pyenv(Version=pythonPath);
end

py_version = currentPyenv.Version;

%disp(matlab_release);
%disp(py_version);

% create matlab_python_version compatibilty_dict, taken from here: https://de.mathworks.com/support/requirements/python-compatibility.html

matlab_python_dict = containers.Map;
matlab_python_dict('R2024b') = [3.9, 3.10, 3.11, 3.12];
matlab_python_dict('R2024a') = [3.9, 3.10, 3.11];
matlab_python_dict('R2023b') = [3.9, 3.10, 3.11];
matlab_python_dict('R2023a') = [3.8, 3.9, 3.10];
matlab_python_dict('R2022b') = [3.8, 3.9, 3.10];
matlab_python_dict('R2022a') = [3.8, 3.9];
matlab_python_dict('R2021b') = [3.7, 3.8, 3.9];


% Check if the Python version is a value for the key of the actual matlab-version from the matlab_python_dict'
if isKey(matlab_python_dict, matlab_release)
    values = matlab_python_dict(matlab_release);
    if any(values == sscanf(py_version, '%f'))
        %disp(['Python version ', num2str(py_version), ' is supported in ', matlab_release, '.']);
        disp(['pyrun can be executed. Glued_signal will be calculated.']);
    else
        disp(['Python version ', num2str(py_version), ' is NOT supported in ', matlab_release, '.']);
        disp(['pyrun can NOT be executed. Glued_signal can NOT be calculated.']);
        return;
    end
else
    disp('Key ',matlab_release,'  does not support pyrun.');
    disp(['pyrun can NOT be executed. Glued_signal can NOT be calculated.']);
    return;
end


pyrun("import lib.qc.gluing_functions as glueing");


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
