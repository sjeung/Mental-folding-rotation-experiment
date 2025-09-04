function mfold_Save

global data;

% easily update from comment in core function (where the data matrix lines are created
headerString = 'Abs_trial_no\tBlock_number\tTrial_number\tIti_duration\tRef_stimSide\tTar_stimSide\tRef_stimulus\tTar_stimulus\tRespons_Code\tResp_Correct\tReactio_Time\tNom_refStDur\tAct_refStDur\n';

% save data matrix header line (in case separately needed) to a header text file
fid = fopen(data.prefs.output.headFilename,'w');
fprintf(fid,headerString);
fclose(fid);

% save data matrix header line as first line to data text file
fid = fopen(data.prefs.output.dataFilename,'w');
fprintf(fid,headerString);
fclose(fid);

% append data matrix to data text file with prepared header line
dlmwrite(data.prefs.output.dataFilename, data.output.results, '-append', 'delimiter', '\t', 'newline', 'pc');

% save data matrix without header line (e.g. for Matlab's 'dlmread' function) to a data text file
dlmwrite([data.prefs.output.dataFilename(1:end-4),'_withoutHeaderLine.dat'], data.output.results, 'delimiter', '\t', 'newline', 'pc');

% save the complete experiment variable 'data' to a Matlab data file
save(data.prefs.output.matfFilename,'data');

