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

%%
global C_disch rho_amb vol_b P_atm gamma rho_W D_tht D_b R M_b C_drg P_gage ...
    vol_wi T_ai g vol_ai P_AbsAir M_ai M_wi vWindx vWindy thrust check ThermoX ThermoY ThermoZ

%preallocate thrust matrix
thrust = [];
check = 1;

dir = input('Direction (N, NE, E, SE, ect.): ', 's');
speed = input('Wind Speed [mph]: ') * 0.44704; % converted from mph to m/s
switch dir
    case 'N'
        vWindx = speed * cosd(30);
        vWindy = -speed * sind(30);
    case 'NE'
        vWindx = speed * sind(15);
        vWindy = -speed * cosd(15);
    case 'E'
        vWindx = -speed * cosd(60);
        vWindy = -speed * sind(60);
    case 'SE'
        vWindx = -speed * cosd(15);
        vWindy = -speed * sind(15);
    case 'S'
        vWindx = -speed * cosd(30);
        vWindy = speed * sind(30);
    case 'SW'
        vWindx = -speed * sind(15);
        vWindy = speed * cosd(15);
    case 'W'
        vWindx = speed * cosd(60);
        vWindy = speed * sind(60);
    case 'NW'
        vWindx = speed * cosd(15);
        vWindy = speed * sind(15);
end

%% Initializing parameters
P_gage = 40 * 6894.76;      % Pa - Initial gage pressure of air in bottle
vol_wi = 0.00053;           % m^3 - Initial volume of water in the bottle
theta0 = 45 * pi/180;       % radians - initial angle of rocket from horizontal
rho_W = 1000;               % kg/m^3 - Water density
C_drg = 0.39;               % Coefficient of Drag.

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
M_b = 0.128;                % kg - Mass of empty bottle
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

%% Plotting
figure();
plot3(F(:, 4) * 3.28084, F(:, 5) * 3.28084, F(:, 6) * 3.28084)
zlabel('Vertical Height [ft]');
xlabel('Downrange Distance [ft]')
ylabel('Crossrange Distance [ft]')

distance = norm(F(end, 4:6)) * 3.28084;
angle = atand(F(end, 5)./F(end, 4));

fprintf('Distance Travelled [ft]: %.1f\nAngle: %.1f deg\nVolume of Water needed %.3f [L]\n', distance, angle, vol_wi*10^3)

%% Thrust Analysis
%eliminate trailing zero thrust values of ballistic stage
p = find(thrust(:,2) == 0);
thrust(p,:) = [];
%orgnize the rows so that they are in chronological order (fault of ode45)
thrust = sortrows(thrust,1);
%define a line of best fit
[coeff] = polyfit(thrust(:,1),thrust(:,2),3);
fT = polyval(coeff,thrust(:,1));

figure
plot(thrust(:,1), thrust(:,2),'.')
title('Thermodynamic Model Thrust'); xlabel('Time, [s]'); ylabel('Thrust, [N]');
ylim([0 300])

%% Plot video data, thermo. model trajectory, altimeter max height
%determine stats from video and altimeter
[X,Y,max_alt] = Data_Analysis;

%plot
figure
hold on
plot(F(:,4) * 3.28084,F(:,6) * 3.28084,'--')
plot(X,Y)
plot([0 240], [max_alt max_alt],'--k')
legend('thermodynamic model','video data','max height from altimeter','Location','Best')
title('Video Analysis')
xlabel('Down range, [ft]')
ylabel('Height, [ft]')


% write trajecotyr to globals to be overlaid with other models
ThermoX = F(:,4)* 3.28084; ThermoY = F(:,5)* 3.28084; ThermoZ = F(:,6)* 3.28084;

%% Fin

