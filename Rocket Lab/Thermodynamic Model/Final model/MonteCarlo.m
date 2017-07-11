%Bottle Rocket Lab
%ASEN 2004
%Auther: Benjamin Hagenau
%Created: 3/15/17

function MonteCarlo
clc
%% Initializing all the little constants globally
global C_disch rho_amb vol_b P_atm gamma rho_W D_tht D_b R M_b C_drg P_gage ...
    vol_wi T_ai g vol_ai P_AbsAir M_ai M_wi vWindx vWindy 

figure
for i = 1:100
    %define parameters to be changed
    C_drg = .4 + .1*rand(1)*sign(randi([-1 1]));         % Drag coefficient
    P_gage = 275790 + 1000*rand(1)*sign(randi([-1 1]));  % Pa - Initial gage pressure of air in bottle
    vol_wi = .0005 + .00002*rand(1)*sign(randi([-1 1]));  % m^3 - Initial volume of water in the bottle
    theta0 = (45 + 2*rand(1)*sign(randi([-1 1])))*pi/180;% radians - initial angle of rocket from horizontal
    vWindx = 0 + 10*rand(1)*sign(randi([-1 1]));         %wind speed
    vWindy = 0 + 10*rand(1)*sign(randi([-1 1]));
    M_b = 0.128 + .01*rand(1)*sign(randi([-1 1]));        % kg - Mass of empty bottle

    %define initial conditions
    rho_W = 1000;               % kg/m^3 - Density of water
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
    X = F(:,4)*3.28084; Y = F(:,5)*3.28084; Z = F(:,6)*3.28084;
    
    %store landing spot
    landing(i,:)  = [X(end) Y(end)];
    
    %plot
    plot3(X,Y,Z)
    title('Monte Carlo Trajectories')
    axis equal; xlabel('Down Range [ft]'); ylabel('Cross Range [ft]'); hold on;
    hold on
end
hold off

%error ellipses
figure; 
plot(landing(:,1),landing(:,2),'k.','markersize',6)
title('Error Ellipses')
axis equal; grid on; xlabel('Down Range [ft]'); ylabel('Cross Range [ft]'); zlabel('Height [ft]'); hold on;
% Calculate covariance matrix
P = cov(landing(:,1),landing(:,2)); mean_x = mean(landing(:,1)); mean_y = mean(landing(:,2));
% Calculate the define the error ellipses
n=100; % Number of points around ellipse
p=0:pi/n:2*pi; % angles around a circle
[eigvec,eigval] = eig(P); % Compute eigen-stuff
xy_vect = [cos(p'),sin(p')] * sqrt(eigval) * eigvec'; % Transformation x_vect = xy_vect(:,1);
x_vect = xy_vect(:,1);
y_vect = xy_vect(:,2);
% Plot the error ellipses overlaid on the same figure
plot(1*x_vect+mean_x, 1*y_vect+mean_y, 'b'); %plot error ellipses
plot(2*x_vect+mean_x, 2*y_vect+mean_y, 'g'); 
plot(3*x_vect+mean_x, 3*y_vect+mean_y, 'r');
text(139*cos(17.3*pi/180),139*sin(17.3*pi/180),'landing position')
plot(139*cos(17.3*pi/180)-5,139*sin(17.3*pi/180),'*') %plot landing position

hold off

    
    
    