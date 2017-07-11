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

% Some plotting to get the picture
plotsettings;
figure();
hold on
plot(tVec, testLoad, 'b')
plot(trimmedtVec, loadAdj, 'r')
plot(trimmedtVec, interpVec, 'g')

plot(t_0, testLoad(t_0Ndx), 'kx', 'MarkerSize', 15)
plot(t_f, testLoad(t_fNdx), 'kx', 'MarkerSize', 15)

xlabel('Time [s]')
ylabel('Force [N]')
title('Static Test Stand Data')
axis([0.5 1.5 -50 250])
legend('Original Data', 'Adjusted Data', 'Interpolation for Adjustment')

% Isp calculation
I_sp = trapz(trimmedtVec, trimmedLoad) / (mProp * g);

end
