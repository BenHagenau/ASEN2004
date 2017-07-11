%{
Rocket Equation Model: Calculates Specific Impulse based on static test
stand data and uses it in the idea rocket equation to get the initial
velocity of the rocket track its path with that. 


Created: 3/22/17 - Connor Ott
Last Modified: 4/3/17 - Connor Ott
%}

% clear variables
close all
clc
plotsettings;

global g m_0 vWindx vWindy theta C_Dbottle IspX IspY IspZ
g = 9.81;
%% Getting the Isp and initial V for the trajectory of the rocket.
m_dry = 0.1054; % kg
m_final = 0.1072; % kg
m_prop = 0.53; % kg
I_sp = ispAnalysis('Group13_10AM_statictest2', m_prop);

% Calculating the delta V based on I_sp. 
deltaV = I_sp * g * (log(m_dry + m_prop) - log(m_final)); % m/s

% Delta V is taken to be the inital velocity of the Rocket, and now we say
% there is no more thrust pushing the rocket forward.

%% Determining Coefficient of Drag
C_D = dragCoeff('WTData13_test 2.csv');
C_Dbottle = C_D(5);
%% Calling ode45 with initial velocity and position
%{ 
Things that change now:
Velocity
Position
Drag - changes as a function of velocity
that might be it
%}

% Splitting components of the initial velocity between x and z directions
% based on launch angle. 
theta = 45; % degrees - may be altered. 
V_0x = deltaV * cosd(theta); % m/s 
V_0z = deltaV * sind(theta); % m/s
V_0y = 0; % m/s - (windspeed will be tacked on if applicable, making this non-zero)

% User input for windspeed before test (I'll keep it at 3 each for now)
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


% vWindx = 0; % m/s only one measurement for now (not low and high measurements)
% vWindy = 0; % m/s


[X_0x, X_0y, X_0z] = deal(0); % m - Inital position at (0,0,0) 
m_0 = m_final; % no more propellant - new m_0 for ballistic phase

t0 = 0; % s
tf = 4; % s

initialVals = [V_0x, V_0y, V_0z, 0, 0, 0];

[time, F] = ode45('rocketEqnODE', [t0 tf], initialVals);
figure(2)
plot3(F(:, 4) * 3.28084, F(:, 5) * 3.28084, F(:, 6) * 3.28084);
title('Isp Model Trajectory')
xlabel('Downrange Distance [ft]')
ylabel('Crossrange Distance [ft]')
zlabel('Vertical Position [ft]')

range = norm([F(end, 4), F(end, 5)]);
fprintf('Range: %.2f ft\nAngle: %.2f degrees\n', range * 3.28084, atand(F(end, 5)/F(end, 4)));

%make trajectories to be overlaid using global variables
IspX = F(:,4)* 3.28084; IspY = F(:,5)* 3.28084; IspZ = F(:,6)* 3.28084;








