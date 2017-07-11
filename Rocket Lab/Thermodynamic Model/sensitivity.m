%Bottle Rocket Lab
%ASEN 2004
%Auther: Benjamin Hagenau
%Created: 4/12/17

%Sensitivity Analysis

%water volume
%water density 
%Air pressure 
%coefficient of drag
%launch angle

function sensitivity

global volume_rocket pa  rho_water...
    R mass_rocket C p0 v0 T0 z0 x0 y0 Vx0 Vy0 Vz0 C_baseline p0_basline...
    rho_water_baseline v0_baseline V0 Vx0_baseline Vy0_baseline Vz0_baseline
tspan = [0,10];                                       %define time range
iterations = 50;                                      %define number of iterations 

%% Initial Water Volume
figure
range = linspace(.0001, .002, iterations);                              %lowst/base line = .0001 m^3 | highest = .002 m^3
hold on
for i = range
    v0 = i;  
    m0t = mass_rocket + rho_water*(volume_rocket - v0) + (p0*v0)/(R*T0); %[kg]%define new initial water volume
    m0 = (p0*v0)/(R*T0);                                                 %[kg]
    y = [v0 Vx0 Vy0 Vz0 x0 y0 z0 m0t m0];                                %define initial conditions
    [t,y] = ode45('trajectory',tspan,y);
    X = y(:,5); Y = y(:,6); Z = y(:,7);
    %plot
    hold on
    subplot(1,2,1)
    plot3(X,Y,Z)
    title('Trajectory')
    xlabel('South')
    ylabel('East')
    hold off
    hold on
    subplot(1,2,2)
    plot(i,norm([max(X),max(Y)])*3.28084,'*') %[feet]
    title('Sensitivity Analysis: Initial Water Volume')
    xlabel('initial water volume, m^3')
    ylabel('range, ft')
    hold off
end
%redefine to base line value for next analysis
v0 = v0_baseline;

%% Water Density
figure
range = linspace(1000, 2000, iterations);                                %lowest/baseline = 1000 | highest = 2000 
for i = range
    rho_water = i;                                                       %define new water density
    m0t = mass_rocket + rho_water*(volume_rocket - v0) + (p0*v0)/(R*T0); %[kg]
    m0 = (p0*v0)/(R*T0);                                                 %[kg]
    y = [v0 Vx0 Vy0 Vz0 x0 y0 z0 m0t m0];                                %define initial conditions
    [t,y] = ode45('trajectory',tspan,y);
    X = y(:,5); Y = y(:,6); Z = y(:,7);
    %plot
    hold on
    subplot(1,2,1)
    plot3(X,Y,Z)
    title('Trajectory')
    xlabel('South')
    ylabel('East')
    hold off
    hold on
    subplot(1,2,2)
    plot(i,norm([max(X),max(Y)])*3.28084,'*') %[feet]
    title('Sensitivity Analysis: Water Denisty')
    xlabel('water density, kg/m^3')
    ylabel('range, ft')
    hold off
end
hold off
%redefine to base line value for next analysis
rho_water = rho_water_baseline;

%% Initial Air Pressure
figure
range = linspace(275790+pa, 137895+pa, iterations);                      %[Pa] lowest = 20 psi | highest/base line = 40 psi (+Patm)
for i = range
    p0 = i;                                                              %define initial air pressure
    m0t = mass_rocket + rho_water*(volume_rocket - v0) + (p0*v0)/(R*T0); %[kg]
    m0 = (p0*v0)/(R*T0);                                                 %[kg]
    y = [v0 Vx0 Vy0 Vz0 x0 y0 z0 m0t m0];                                %define initial conditions
    [t,y] = ode45('trajectory',tspan,y);
    X = y(:,5); Y = y(:,6); Z = y(:,7);
    %plot
    hold on
    subplot(1,2,1)
    plot3(X,Y,Z)
    title('Trajectory')
    xlabel('South')
    ylabel('East')
    hold off
    hold on
    subplot(1,2,2)
    plot(i,norm([max(X),max(Y)])*3.28084,'*') %[feet]
    title('Sensitivity Analysis: Initial Air Pressure')
    xlabel('air pressure, Pa')
    ylabel('range, ft')
    hold off
end
hold off
%redefine to base line value for next analysis
p0 = p0_basline;

%% Coefficient of Drag
figure
m0t = mass_rocket + rho_water*(volume_rocket - v0) + (p0*v0)/(R*T0); %[kg]
m0 = (p0*v0)/(R*T0);                                                 %[kg]

range = linspace(0.1, 0.5, iterations);                              %base line = 0.3874 | lowest = 0.1 | highest = .5
for i = range
    C = i;                                                           %define new coefficient of drag
    y = [v0 Vx0 Vy0 Vz0 x0 y0 z0 m0t m0];                            %define initial conditions
    [t,y] = ode45('trajectory',tspan,y);
    X = y(:,5); Y = y(:,6); Z = y(:,7);
    %plot
    hold on
    subplot(1,2,1)
    plot3(X,Y,Z)
    title('Trajectory')
    xlabel('South')
    ylabel('East')
    hold off
    hold on
    subplot(1,2,2)
    plot(i,norm([max(X),max(Y)])*3.28084,'*') %[feet]
    title('Sensitivity Analysis: Coefficient of Drag')
    xlabel('coefficient of drag')
    ylabel('range, ft')
    hold off
end
hold off
%redefine to base line value for next analysis
C = C_baseline;

%% Launch Angle
figure
m0t = mass_rocket + rho_water*(volume_rocket - v0) + (p0*v0)/(R*T0); %[kg]
m0 = (p0*v0)/(R*T0);                                                 %[kg]

range = linspace(0, 90, iterations);                              %base line = 45 | lowest = 10 | highest = 80
for i = range
    Vx0 = V0*cos(i*pi/180);
    Vy0 = V0*cos(i*pi/180);
    Vz0 = V0*sin(i*pi/180);
    y = [v0 Vx0 Vy0 Vz0 x0 y0 z0 m0t m0];                            %define initial conditions
    [t,y] = ode45('trajectory',tspan,y);
    X = y(:,5); Y = y(:,6); Z = y(:,7);
    %plot
    hold on
    subplot(1,2,1)
    plot3(X,Y,Z)
    title('Trajectory')
    xlabel('South')
    ylabel('East')
    hold off
    hold on
    subplot(1,2,2)
    plot(i,norm([max(X),max(Y)])*3.28084,'*') %[feet]
    title('Sensitivity Analysis: Launch Angle')
    xlabel('launch angle, degrees')
    ylabel('range, ft')
    hold off
end
hold off
%redefine to base line value for next analysis
Vx0 = Vx0_baseline;
Vy0 = Vy0_baseline;
Vz0 = Vz0_baseline;





