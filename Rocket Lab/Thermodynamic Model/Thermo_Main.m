%Bottle Rocket Lab
%ASEN 2004
%Auther: Benjamin Hagenau
%Created: 3/15/17

%%%%%%%%%%%%%%%%%%%%%%%%%%% THERMODYNAMIC MODEL %%%%%%%%%%%%%%%%%%%%%%%%%%%

%PURPOSE: To determine the trajectory of a bottle rocket that lands it 85
%meters within one meter from the launch position. The purpose is to also
%determine the initial parameter that effects the flight the most.
%INPUT:This code calls functions to do these tasks.
%OUTPUT:The trajectory of the rocket, the initial air pressure that lands
%the rocket 85 meters away, and the variables that effect the height and
%distance the most. 
%ASSUMPTIONS:Isentropic fluid expansion, initial temperature of air is in
%equilibrium with STP

%House Keeping
clear all
close all
clc

%Main Script

%plot settings
plotsettings

global thrust Cd rho_a volume_rocket pa gamma rho_water...
    At A R mass_rocket C p0 v0 T0 m0 m0t z0 x0 y0 Vx0 Vy0 Vz0 C_baseline...
    p0_basline rho_water_baseline v0_baseline conf Vx0_baseline Vy0_baseline Vz0_baseline V0
thrust = [];
conf.wind = [-.5,.5,0]./[cos(15*pi/180),cos(15*pi/180),1]*0.44704; %[mi/h] -> [m/s] [south(+) east(+) zenith] (project axis) (launch in X-Y at 45 degrees)
conf.g = [0 0 9.80665];

% Define Coefficients and Run ODE45
%units: SI and Radians
%DEFINE CONSTANTS
Cd                      = 0.8;              %discharge coefficient
rho_a                   = .961;             %[kg/m^3]
volume_rocket           = .002;             %[m^3] 
pa                      = 82943.93;         %[Pa]
gamma                   = 1.4;              %specific heat ratios
rho_water               = 1000;             %[kg/m^3]
At                      = ((.021/2)^2)*pi;  %[m^2] %area of throat
R                       = 287;              %[J/(kg K)]
mass_rocket             = .115;             %[kg]
C                       = 0.392;             %drag coefficient
p0                      = 361790;           %[Pa] (absolute)
v0                      = 0.0015;           %[m^3] 
T0                      = 300;              %[K]
A                       = pi*(0.05)^2;      %4 [in] -> [m] frontal area

%define launch angle and low initial velocity
launch_angle = 45;
V0 = .1;

%store base line values that are used and changed in other code
C_baseline = 0.329;
p0_basline = 275790 + pa;
rho_water_baseline = 1000;
v0_baseline = 0.0005;
Vx0_baseline = V0*cos(launch_angle*pi/180);
Vy0_baseline = V0*cos(launch_angle*pi/180);
Vz0_baseline = V0*sin(launch_angle*pi/180);

%patm = 86000 pa
%40 psi = 275790 pa

%define initial conditions for each equation and store in matrix y
x0 = 0;          %[m]
y0 = 0;          %[m]
z0 = .1;         %[m]
m0t = mass_rocket + rho_water*(volume_rocket - v0) + (p0*v0)/(R*T0); %[kg]
%m0t = 1.617;
m0 = (p0*v0)/(R*T0); %[kg]

tspan = [0,10]; %add time step wanted in output

%DETERMINE TRAJECTORY USING ODE45
Vx0 = V0*cos(launch_angle*pi/180);
Vy0 = V0*cos(launch_angle*pi/180);
Vz0 = V0*sin(launch_angle*pi/180);
y = [v0 Vx0 Vy0 Vz0 x0 y0 z0 m0t m0];
[t,y] = ode45('trajectory',tspan,y);

X = y(:,5); Y = y(:,6); Z = y(:,7);

%plot trajectory
figure
hold on
plot3(X*3.28084,Y*3.28084,Z*3.28084)
title('Rocket Trajectory')
plot3([0 max(X)*3.28084+10],[0 max(X)*3.28084+10],[0 0],'k--')

zlabel('Height, [ft]')
xlabel('Down Range, [ft]')
ylabel('Cross Range, [ft]')

view(3)
hold off

%plot Thrust
Thrust

%determine angle 
flight_angle = atan(max(X)/max(Y))*180/pi - 45; %[degrees]

%print out
fprintf('Distance Travelled: %3.3f feet\n',norm([max(X),max(Y)])*3.28084)
fprintf('Max Height: %3.3f feet\n',max(Z)*3.28084')
fprintf('Launch Angle: %.1f degrees\n',launch_angle)
fprintf('Flight Angle: %.1f degrees\n',flight_angle)

 w = find(Z > 0)
 w1 = w(end)
 t(w1)

%% sensitivity analysis
sensitivity

%% MonteCarlo
MonteCarlo




