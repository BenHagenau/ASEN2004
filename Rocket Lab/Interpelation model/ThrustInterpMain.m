%function ThrustInterpMain
%Initial conditions:
close all
%clear variables
clc

global rho mbottle m0 Theta1 theta g vWindx vWindy IntX IntY IntZ

g= 9.81; %m/s
m_prop = 0.53; % kg
mbottle = 0.128; % kg
m0 = mbottle + m_prop; % kg
rho = 1000; % kg/m^3
Theta1 = 45*pi/180; % rad
theta = Theta1; % discrepancy between Ashley's code and mine. 


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


data = load('Group13_10AM_statictest2'); % Read in

testLoad = data(:,3)*4.44822; % Converting to newtons
tVec = linspace(0,(12000/1652),12000); % Time vector - based on frequency of sampling and number of samples

% Adjusting Data
t_maxNdx = find(testLoad == max(testLoad));
t_max = tVec(t_maxNdx);
t_0Ndx = 1470; 
t_0 = tVec(1470);
t_fNdx = 1800;
t_f = tVec(1800);

% Trimming the data to be integrated
trimmedLoad = testLoad(t_0Ndx:t_fNdx); 
trimmedtVec = tVec(t_0Ndx:t_fNdx);

% Vector which will be used to adjust the data
interpVec = linspace(testLoad(t_0Ndx), testLoad(t_fNdx), ...
    numel(trimmedLoad));
loadAdj = trimmedLoad - interpVec'; % Adjusted data

%Running ODE45
tspan= trimmedtVec - trimmedtVec(1);
[Vx_0, Vy_0, Vz_0, x_0, y_0, z_0] = deal(0);
initialVals = [Vx_0, Vy_0, Vz_0, x_0, y_0, z_0, m0];

% First phase, thrusting phase
[time1,val1]=ode45(@(time, val) FindThrust(time, val, loadAdj, tspan),tspan,initialVals);

% Already have code for ballistic phase, run rocketEqnODE with final
% conditions of previous ode. 
t0 = time1(end);
tf = 5;
initialVals2 = val1(end, 1:6);
[time2, val2] = ode45('rocketEqnODE', [t0 tf], initialVals2);

% Plotting both sets of data
figure(2);
plot3(val1(:, 4)*3.28084, val1(:, 5)*3.28084, val1(:, 6)*3.28084);
hold on
plot3(val2(:, 4)*3.28084, val2(:, 5)*3.28084, val2(:, 6)*3.28084)
xlabel('Downrange Position [ft]')
ylabel('Crossrange Position [ft]')
zlabel('Vertical Position [ft]')

%make trajectory globals to be compiled with other models
IntX = [val1(:,4); val2(:,4)]*3.28084; IntY = [val1(:,5); val2(:,5)]*3.28084; IntZ = [val1(:,6); val2(:,6)]*3.28084;







