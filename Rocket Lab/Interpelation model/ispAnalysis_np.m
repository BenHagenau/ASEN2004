function [I_sp] = ispAnalysis(fileName, mProp)
%{
Isp analysis function. Runs through each set of student static test stand
data and determines Isp, along with other statistics.

Created: 4/11/17 - Connor Ott
Last Modified: 4/11/17 - Connor Ott
%}

global g
data = load(fileName); % Read in

testLoad = data(:,3)*4.44822; % Converting to newtons
tVec = linspace(0,(12000/1652),12000); % Time vector

t_maxNdx = find(testLoad == max(testLoad));
t_max = tVec(t_maxNdx);
t_0Ndx = 1470; 
t_0 = tVec(1470);
t_fNdx = 1800; % looking for endpoint, generally marked by the minimum value
t_f = tVec(1800);

% Trimming the data to be integrated
trimmedLoad = testLoad(t_0Ndx:t_fNdx); 
trimmedtVec = tVec(t_0Ndx:t_fNdx);

% Vector which will be used to adjust the data
interpVec = linspace(testLoad(t_0Ndx), testLoad(t_fNdx), ...
    numel(trimmedLoad));
loadAdj = trimmedLoad - interpVec'; % Adjusted data

% Isp calculation
I_sp = trapz(trimmedtVec, loadAdj) / (mProp * g);


end

