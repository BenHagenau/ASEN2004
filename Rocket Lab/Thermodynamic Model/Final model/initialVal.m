

%this function resets the initial values for the bottle rocket trajectory

function [y0] = initialVal

global  P_gage vol_wi C_disch rho_amb vol_b P_atm gamma rho_W D_tht D_b R M_b ...
     T_ai g vol_ai P_AbsAir M_ai M_wi theta0

%vary all parameters that are not being changed
rho_W = 1000;
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
y0 = [V0_x; V0_y; V0_z; x0; y0; z0; theta0; M_ai; vol_a0; mass0];