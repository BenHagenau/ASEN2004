%Bottle Rocket Lab
%ASEN 2004
%Auther: Benjamin Hagenau
%Created: 3/16/17

%This function plots the thrust as a function of time for the thermodynamic
%water bottle rocket model for the 2004 rocket lab.

function Thrust

global thrust

%take the magnitude of the thrust
for i = 1:length(thrust(:,1))
    thrust(i,2) = norm(thrust(i,2:4));
    thrust(i,3) = 0;
    thrust(i,4) = 0;
end

%eliminate outliers calculated by ode 45
% p = find(thrust > 400);
% thrust(p) = [];
% time(p) = [];
%eliminate trailing zero thrust values of ballistic stage
p = find(thrust(:,2) == 0);
thrust(p,:) = [];
%orgnize the rows so that they are in chronological order (fault of ode45)
thrust = sortrows(thrust,1);
%define a line of best fit
[coeff] = polyfit(thrust(:,1),thrust(:,2),3);
fT = polyval(coeff,thrust(:,1));

%plot
figure
hold on
plot(thrust(:,1),thrust(:,2),'.')
%plot(thrust(:,1),fT)
title('Thrust: Thermodynamic Model')
xlabel('time, s')
ylabel('thrust, N')
legend('Thrust measurements','Line of best fit')
hold off