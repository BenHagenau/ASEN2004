function [dfdt] = var(time,val,data,timenew)
%Ode45 for thrust for ballistic phase
global rho mbottle mwater m0 A rhoAir VolAir0 mAir0 mRocket Vel1 Theta1 X0 Z0 Cdrag g vWindx vWindy

V_g = [val(1), val(2), val(3)]; % Ground Speed [x, y, z] m/s
R = [val(4), val(5), val(6)]; % Positon [x, y, z] m
m = val(7);
V_rel = [V_g(1) - vWindx, V_g(2) - vWindy, V_g(3)]; % Relative wind speed [x, y, z] m/s

rho_amb = 1; % kg/m^3
C_drg = 0.39;
%%

A_b = pi * (0.0560832)^2 ; % m^2
dfdt = zeros(7, 1);

if time > 0.1
   flag = 1; 
end

T0= abs(interp1(timenew, data, time)); %interpolation - thrust
Vexit = sqrt(T0/(rho*A_b));
dmdt= -rho*A_b*Vexit;


if norm(R) < 2 * 0.3048 % if the rocket hasn't left the 2 ft rails
    head = [cos(Theta1), 0, sin(Theta1)];
    F_g = [0, 0, 0];
else
    head = V_rel/norm(V_rel); % Heading vector (direction of rocket)
    F_g = [0, 0, -g * m];
end
    

Tvec = T0 * head;
D = rho_amb/2 * norm(V_rel)^2 * C_drg * A_b * head; % N - Drag force
dV_gdt = (Tvec + F_g - D)/m;

dRdt = V_g;

dfdt(1:3) = dV_gdt;
dfdt(4:6) = dRdt;
dfdt(7) = dmdt;
end


