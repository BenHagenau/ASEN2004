%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Author: Benjamin Hagenau                                              %
%   Date Created: 02/01/17                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Purpose: Reads in / extracts necessary data from Experimental Lab 1   %
%   data for the CLEAN F-16. Data is averaged from all groups' results    %
%   at each angle of attack.                                              %
%                                                                         %
%   @input: File names (data for each group testing the clean F-16)       %
%   @output: Data matrices for aircraft at 0 and 25 m/s airspeed,         %
%   air density (averaged)                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%AoA [-8 20]
    %odd numbers do odd angles of attack 
    %even numbers do even angles of attack
%F-16 clean G(1-4)(11-14)(23-26) (12) (200 data points for each)
%20 data points at each angle of attack

function [F16_clean,rhoF16_clean,F16_clean0] = readF16_clean()
F16_clean0 = zeros(1,length([3:4 23:26]));
F16_clean25 = zeros(1,length([3:4 23:26]));

for i = [1:4 11:14 23:26]
%declare data file
    if i < 10
        fileF16_clean = sprintf('F16_CLEAN_G0%d.csv',i);
    else
        fileF16_clean = sprintf('F16_CLEAN_G%d.csv',i);
    end
%read in data file and select columns needed
    matF16_clean = csvread(fileF16_clean,1,0);
    matF16_clean = matF16_clean(:,[3:4 23:26]); %define columns needed
%define zero wind speed and 25 m/s wind speed
    F16_clean0 = [F16_clean0; matF16_clean(1:300,:)];
    F16_clean25 = [F16_clean25; matF16_clean(301:end,:)];
end

%sort rows in ascending order
F16_clean0 = sortrows(F16_clean0,3);
F16_clean25 = sortrows(F16_clean25,3);

%determine air density
rhoF16_clean = mean(F16_clean25(:,1));

%determine the true force applied to the air craft by the wind
F16_clean(:,3) = F16_clean25(:,3);
F16_clean(:,4:6) = F16_clean25(:,4:6) - F16_clean0(:,4:6);
F16_clean(:,1:2) = F16_clean25(:,1:2);
for i = 1:6
    F16_clean(9,i) = mean([F16_clean(9,i) F16_clean(10,i)]);
end
F16_clean(10,:) = [];

end
