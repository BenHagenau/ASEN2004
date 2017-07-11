%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Author: Benjamin Hagenau                                              %
%   Date Created: 02/01/17                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Purpose: Reads in / extracts necessary data from Experimental Lab 1   %
%   data for the B787 model. Data is averaged from all groups' results    %
%   at each angle of attack.                                              %
%                                                                         %
%   @input: File names (data for each group testing the B787)             %
%   @output: Data matrices for aircraft at 0 and 25 m/s airspeed,         %
%   air density (averaged)                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%AoA [-8 20]
    %odd numbers do odd angles of attack 
    %even numbers do even angles of attack
%787 G(9-10)(19-22)(31-34) (10)
%20 data points at each angle of attack

function [M787,rhoM787,M787_0] = read787()
M787_0 = zeros(1,length([3:4 23:26]));
M787_25 = zeros(1,length([3:4 23:26]));

for i = [9:10 19:22 31:36]
%declare data file
    if i < 10
        fileM787 = sprintf('787_G0%d.csv',i);
    else
        fileM787 = sprintf('787_G%d.csv',i);
    end
%read in data file and select columns needed
    mat787 = csvread(fileM787,1,0);
    mat787 = mat787(:,[3:4 23:26]); %define columns needed
%define zero wind speed and 25 m/s wind speed
    M787_0 = [M787_0; mat787(1:300,:)];
    M787_25 = [M787_25; mat787(301:end,:)];
end

%sort rows in ascending order
M787_0 = sortrows(M787_0,3);
M787_25 = sortrows(M787_25,3);

%determine air density
rhoM787 = mean(M787_25(:,1));

%determine the true force applied to the air craft by the wind
M787(:,3) = M787_25(:,3);
M787(:,4:6) = M787_25(:,4:6) - M787_0(:,4:6);
M787(:,1:2) = M787_25(:,1:2);
for i = 1:6
    M787(9,i) = mean([M787(9,i) M787(10,i)]);
end
M787(10,:) = [];


end