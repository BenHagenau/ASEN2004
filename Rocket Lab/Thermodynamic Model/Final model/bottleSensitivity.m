%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Varies the parameters which can be altered to change the range of the
% rocket and plots the results of each variation.
%
% Inputs: 
%   Requires that pieceWiseODE.m is included in the same folder. 
% 
% Outputs:
%   Plots the vertical and horizontal position of the rocket with respect 
%   to time on  MATLAB figure. 
%
% Created: 11/20/16 - Connor Ott
% Last Modified: 11/22/16 - Connor Ott
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear variables
close all
clc
plotsettings;
check = 0;
%% Initializing all the little constants globally
global C_disch rho_amb vol_b P_atm gamma rho_W D_tht D_b R M_b C_drg P_gage ...
    vol_wi T_ai g vol_ai P_AbsAir M_ai M_wi vWindx vWindy check

vWindx = 0;
vWindy = 0;

% Vectors with ranges to vary the parameters
C_drgV = linspace(0.3, 0.5, 100);
P_gageV = linspace(35, 45, 100) * 6894.76;
vol_wiV = linspace(1e-5, 0.001, 100);
theta0V = linspace(30, 60, 100) * pi/180;
rhoV = linspace(500, 1500, 100);

% Celery with all the varyiance of parameters
varyCell = {C_drgV; P_gageV; vol_wiV; theta0V; rhoV};
maxXCell = cell(5, 1);
paths = cell(5, 100);
times = cell(5, 100);
t_optimal = cell(5, 1);
optimalPathPredict = cell(5, 1);
optimalVar = zeros(5, 1);

% Just some stuff for the plotting
titles = {'Drag Variance', 'Gage Pressure Variance', '$Vol_w$ Variance',...
    'Initial Angle Variance', 'Water Density Variance'};
xlabels = {'Drag Coefficient', 'Initial Gage Pressure [psi]',...
    'Initial Volume of Water [$m^3$]', 'Initial Angle [Rad]', 'Water Density [$kg/m^3$]'};


for i = 1:5 % Varying each parameter (4 parameters)
    maxXtmp = zeros(length(varyCell{i}), 1); % Temporary vector to hold the max distances calculated from each variance
    for j = 1:length(varyCell{i}) % Varying them however many times (100 it looks like)
        switch i
            case 1
                C_drg = varyCell{i}(j);     % Drag coefficient (VARIED)
                P_gage = 40 * 6894.76;      % Pa - Initial gage pressure of air in bottle
                vol_wi = 0.001;             % m^3 - Initial volume of water in the bottle
                theta0 = 45 * pi/180;       % radians - initial angle of rocket from horizontal
                rho_W = 1000;               % kg/m^3 - Density of water
            case 2
                C_drg = 0.39;               % Drag coefficient
                P_gage = varyCell{i}(j);    % Pa - Initial gage pressure of air in bottle (VARIED)
                vol_wi = 0.001;             % m^3 - Initial volume of water in the bottle
                theta0 = 40 * pi/180;       % radians - initial angle of rocket from horizontal
                rho_W = 1000;               % kg/m^3 - Density of water
            case 3
                C_drg = 0.39;               % Drag coefficient
                P_gage = 40 * 6894.76;      % Pa - Initial gage pressure of air in bottle
                vol_wi = varyCell{i}(j);    % m^3 - Initial volume of water in the bottle (VARIED)
                theta0 = 45 * pi/180;       % radians - initial angle of rocket from horizontal
                rho_W = 1000;               % kg/m^3 - Density of water
                if j == 58
                   flag = 1; 
                end
            case 4
                C_drg = 0.39;               % Drag coefficient
                P_gage = 40 * 6894.76;      % Pa - Initial gage pressure of air in bottle
                vol_wi = 0.001;             % m^3 - Initial volume of water in the bottle
                theta0 = varyCell{i}(j);    % radians - initial angle of rocket from horizontal (VARIED)
                rho_W = 1000;               % kg/m^3 - Density of water
            case 5
                C_drg = 0.39;               % Drag coefficient
                P_gage = 40 * 6894.76;      % Pa - Initial gage pressure of air in bottle
                vol_wi = 0.001;             % m^3 - Initial volume of water in the bottle
                theta0 = 45 * pi/180;        % radians - initial angle of rocket from horizontal (VARIED)
                rho_W = varyCell{i}(j);     % kg/m^3 - Density of water
        end
        
        C_disch = 0.8;              % Discharge coefficient
        gamma = 1.4;                % Ratio of specific heats
        R = 287;                    % j/kg K - Specific gas constant of air

        P_atm = 12.03 * 6894.76;    % Pa - Atmostpheric pressure (Boulder elev.)
        P_AbsAir = P_atm + P_gage;

        rho_amb = 0.961;            % kg/m^3 - ambient air density

        vol_b = 0.002;              % m^3 - Volume of empty bottle
        vol_ai = vol_b - vol_wi;    % m^3 - inital volume of air in the bottle

        D_tht = 2.1 / 100;          % m - Diameter of throat of bottle
        D_b = 10.5 / 100;           % m - Overall diameter of bottle
        T_ai = 300;                 % K - Initial temperature of air in the bottle
        M_wi = rho_W * (vol_wi);    % kg - initial mass of water
        M_ai = P_AbsAir/(R * ...    % kg - initial mass of air
            T_ai) * (vol_ai);
        M_b = 0.128;                 % kg - Mass of empty bottle
        g = 9.81;                   % m/s^2 - Acceleration due to gravity




        %% Beginning ode45 stuff
        % Initial conditions for ode45

        t0 = 0;                     % s - Initial time for ode45
        tf = 5;                     % s - Final time for ode45
        V0_x = 0;                   % m/s - Initial velocity of rocket
        V0_y = 0;
        V0_z = 0;
        x0 = 0;                     % m - Initial x position of rocket
        y0 = 0;
        z0 = 0;                     % m -  Initial z position of rocket
        T0 = T_ai;                  % K - Initial temperature inside bottle (tbd on necessity)
        rho0 = (P_AbsAir/...
            (R * T_ai) * ...
            (vol_ai)/ vol_b);       % kg - Initial density of air in bottle once water is exhausted.
        P0 = P_AbsAir;              % Pa - Initial air pressure inside bottle (asbolute)
        mass0 = M_b + M_wi + M_ai;  % kg - Initial mass of rocket
        vol_a0 = vol_ai;            % m^3 - Initial volume of air in bottle

        % Putting them all in a vector for ode45
        initialVals = [V0_x; V0_y; V0_z; x0; y0; z0; theta0; M_ai; vol_a0; mass0];

        % Calling ode45 for numerical integration of the odes dictating the rockets
        % path
        [time, F] = ode45('bottleRocketODE', [t0 tf], initialVals);
        paths{i, j} = F;
        times{i, j} = time;
        maxXtmp(j) = norm(F(end, 4:6));
    end
    maxXCell{i} = maxXtmp * 3.28084; % (converting to ft)
    figure;
    if i == 2
        plot(varyCell{i} / 6894.76, maxXCell{i}, '.')
        title(titles{i}, 'FontSize', 18);
        ylabel('Horizontal Distance Travelled [ft]')
        xlabel(xlabels{i})
    else
        plot(varyCell{i}, maxXCell{i}, '.')
        title(titles{i}, 'FontSize', 18);
        ylabel('Horizontal Distance Travelled [ft]')
        xlabel(xlabels{i})
    end
    
    optimalVar(i) = varyCell{i}(find(maxXtmp == max(maxXtmp))); 
    optimalPathPredict{i} = paths{i, find(varyCell{i} == optimalVar(i))} * 3.28084;
    t_optimal{i} = times{i, find(varyCell{i} == optimalVar(i))};
end
% Just for the water volume plot.
i = 3; % sorry I know this is bad please forgive me God.
figure();
plot3(optimalPathPredict{i}(:, 4), optimalPathPredict{i}(:, 5), optimalPathPredict{i}(:, 6))
zlabel('Vertical Height [ft]');
xlabel('Downrange Distance [ft]')
ylabel('Crossrange Distance [ft]')
title('Prediction for 4th Launch')

distance = norm(optimalPathPredict{i}(end, 4:6));
angle = atand(optimalPathPredict{i}(end, 5)./optimalPathPredict{i}(end, 4));
fprintf('Distance Travelled [ft]: %.1f\nAngle: %.1f deg\nVolume of Water needed %.3f [L]\n',...
    distance, angle, optimalVar(i)*10^3)
%% Fin



