%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Author: Benjamin Hagenau                                              %
%   Date Created: 02/01/17                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Purpose: Reads in / extracts necessary data from Experimental Lab 1   %
%   data for the LOADED F-16. Data is averaged from all groups' results   %
%   at each angle of attack.                                              %
%                                                                         %
%   @input: File names (data for each group testing the loaded F-16)      %
%   @output: Data matrices for aircraft at 0 and 25 m/s airspeed,         %
%   air density (averaged)                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%AoA [-8 20]
    %odd numbers do odd angles of attack 
    %even numbers do even angles of attack
%F-16 loaded G(5-8)(15-18)(27-30) (12) (200 data points for each)
%20 data points at each angle of attack

function [F16_loaded,rhoF16_loaded,F16_loaded0] = readF16_loaded()
F16_loaded0 = zeros(1,length([3:4 23:26]));
F16_loaded25 = zeros(1,length([3:4 23:26]));

for i = [5:8 15:18 27:30]
%declare data file
    if i < 10
        fileF16_loaded = sprintf('F16_LOADED_G0%d.csv',i);
    else
        fileF16_loaded = sprintf('F16_LOADED_G%d.csv',i);
    end
%read in data file and select columns needed
    matF16_loaded = csvread(fileF16_loaded,1,0);
    matF16_loaded = matF16_loaded(:,[3:4 23:26]); %define columns needed
%define zero wind speed and 25 m/s wind speed
    F16_loaded0 = [F16_loaded0; matF16_loaded(1:300,:)];
    F16_loaded25 = [F16_loaded25; matF16_loaded(301:end,:)];
end

%sort rows in ascending order
F16_loaded0 = sortrows(F16_loaded0,3);
F16_loaded25 = sortrows(F16_loaded25,3);

%calculate air density
rhoF16_loaded = mean(F16_loaded25(:,1));

%determine the true force applied to the air craft by the wind
F16_loaded(:,3) = F16_loaded25(:,3);
F16_loaded(:,4:6) = F16_loaded25(:,4:6) - F16_loaded0(:,4:6);
F16_loaded(:,1:2) = F16_loaded25(:,1:2);
for i = 1:6
    F16_loaded(9,i) = mean([F16_loaded(9,i) F16_loaded(10,i)]);
end
F16_loaded(10,:) = [];