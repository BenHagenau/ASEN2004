%Bottle Rocket Lab
%ASEN 2004
%Auther: Benjamin Hagenau
%Created: 3/15/17

function MonteCarlo

global Vwind volume_rocket rho_water...
    R mass_rocket C p0 v0 T0 m0 m0t z0 x0 y0 Vx0 Vy0 Vz0 conf Vx0_baseline Vy0_baseline Vz0_baseline

%wind speed (5 mi/hr) (1)
%bottle mass (2 kg) (2)
%coefficient of drag (.1) (3)
%initial air pressure (100 pa) (4)
%starting angle (5 degrees) (5)
figure
title('Monte Carlo Trajectories')
xlabel('South')
ylabel('East')
hold on
for i = 1:100
    %wind velocty
        conf.wind = [conf.wind(1) + 5*rand(1)*sign(randi([-1 1]))*0.44704,...
            conf.wind(2) + 5*rand(1)*sign(randi([-1 1]))*0.44704,...
            conf.wind(3) + 5*rand(1)*sign(randi([-1 1]))*0.44704];
    %coefficient of drag
        C = C + .1*rand(1)*sign(randi([-1 1]));
    %air pressure and rocket mass
        p0 = p0 + 1000*rand(1)*sign(randi([-1 1]));
        m0t = mass_rocket + rho_water*(volume_rocket - v0) + (p0*v0)/(R*T0) + .1*rand(1)*sign(randi([-1 1])); 
        m0 = (p0*v0)/(R*T0);  
    %calculate trajectory
    tspan = [0 10];
    y = [v0 Vx0 Vy0 Vz0 x0 y0 z0 m0t m0];
    [t,y] = ode45('trajectory',tspan,y);
    X = y(:,5); Y = y(:,6); Z = y(:,7);
    
    %plot trajectory
    hold on
    plot3(X,Y,Z)
    title('Trajectory')
    xlabel('South')
    ylabel('East')
    
    %store landing spot
    landing(i,:)  = [X(end) Y(end)];
    
%return variables to origional value
    Vwind = [0, 0, 0];
    p0 = 361790; 
    m0t = mass_rocket + rho_water*(volume_rocket - v0) + (p0*v0)/(R*T0);
    C = 0.3874;
end
hold off

%plot landings
figure
plot(landing(:,1),landing(:,2),'ob')
title('Landing Points')
xlabel('South')
ylabel('East')

%error ellipses
figure; 
title('Error Ellipses')
plot(landing(:,1),landing(:,2),'k.','markersize',6)
axis equal; grid on; xlabel('x [m]'); ylabel('y [m]'); hold on;
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
plot(1*x_vect+mean_x, 1*y_vect+mean_y, 'b'); 
plot(2*x_vect+mean_x, 2*y_vect+mean_y, 'g'); 
plot(3*x_vect+mean_x, 3*y_vect+mean_y, 'r');
hold off




    
    
    