%Author: Benjamin Hagenau
%Created: 1/25/17

%function [F16_loaded, F16_clean, M787] = readDATA()
%This function reads in and extracts data from 2004 experimental lab 1
%data. It outputs cells for each aircraft modle with the data needed.

numGROUP = 34;
for i = numGROUP 
%declare the files under inspection
    if i < 10
        fileF16_loaded = sprintf('F16_LOADED_G0%d',i);
        fileF16_clean = sprintf('F16_CLEAN_G0%d',i);
        file787 = sprintf('787_G0%d',i);
    else
        fileF16_loaded = sprintf('F16_LOADED_G%d',i);
        fileF16_clean = sprintf('F16_CLEAN_G%d',i);
        file787 = sprintf('787_G%d',i);
    end
%read in necessary data from files
%F16 dirty
    matF16_loaded = csvread('fileF16_loaded',1,0);
    matF16_loaded = matF16_loaded(:,[3:4 23:26]); %define columns needed
    F16_loaded{i} = matF16_loaded;
%F16 clean
    matF16_clean = csvread('fileF16_clean',1,0);
    matF16_clean = matF16_clean(:,[3:4 23:26]); %define columns needed
    F16_clean{i} = matF16_clean;
%787 
    mat787 = csvread('file787',1,0);
    mat787 = mat787(:,[3:4 23:26]); %define columns needed
    M787{i} = mat787;
end

%%
%read file
P787 = csvread('F16_LOADED_G06.csv',1,0);

%axial and normal to lift and drag
axial = P787(:,24);
normal = P787(:,25);
AoA = P787(:,23);
moment = P787(:,26);

for i = 302:600
    L(i) = normal(i)*sin(AoA(i)*(pi/180)) + axial(i)*cos(AoA(i)*(pi/180));
    D(i) = normal(i)*cos(AoA(i)*(pi/180)) - axial(i)*sin(AoA(i)*(pi/180));
end


plot(AoA,D,'o')
set(gca,'Ydir','reverse') 