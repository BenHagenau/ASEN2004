%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   ASEN 2004 - Vehicle Design                                            %
%   Experimental Lab 1 - Wind Tunnel Model Testing                        %
%   
%   Author: Benjamin Hagenau                                              %
%   Date Created: 01/30/17                                                %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%   Purpose: Calls functions to read in data tables, calculates model     %
%   weights, finds all aerodynamic values of each model tested            %
%   (F16 - loaded and unloaded, and B787) and plots coefficients of       %
%   lift, drag, and pitching moment against angle of attack, as well as   %
%   drag polar curve and error in data analysis.                          %
%                                                                         %
%   @output: Weights of each model, all plots of aerodynamic qualities,   %
%   and error propagation involved in experimental data collection.       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

%Main

%Read riles and orginize data
%Note: [density, airspeed, AoA, normal, axial, pitch]
[F16_clean,rhoF16_loaded,F16_clean0] = readF16_clean();
[F16_loaded,rhoF16_clean,F16_loaded0] = readF16_loaded();
[M787,rhoM787,M787_0] = read787();

%determine weight of F-16 loaded model using normal sting measuerments
global WF16_loaded WF16_clean W787
WF16_loaded = .2527*9.81;
WF16_clean = .2192*9.81;
W787 = .0939*9.81;

%output weight values
fprintf('Weight of F16 clean: %3.3f [N]\n',WF16_clean)
fprintf('Weight of F16 loaded: %3.3f [N]\n',WF16_loaded)
fprintf('Weight of 787: %3.3f [N]\n\n',W787)

%average densities
rho = mean([rhoF16_loaded rhoF16_clean rhoM787]);

%Determine the lift and drag based on the sting measurements
[q,DATA,STATS] = LiftDrag(F16_clean,F16_loaded,M787);

%Final calculations for lab requirements
analysis(DATA,rho)






