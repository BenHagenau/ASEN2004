function [ dfdt ] = rocketEqnODE( t, f )
% The ODE which will ruin my life. 
global m_0 mbottle vWindx vWindy g theta C_Dbottle

rho_amb = 1; % kg/m^3
C_Dbottle = 0.39;
m_0 = mbottle; % discrepancy between Ashley's code and mine
A_b = pi * (0.0560832)^2 ; % m^2

dfdt = zeros(6, 1);

V_g = [f(1), f(2), f(3)]; % Ground Speed [x, y, z] m/s
R = [f(4), f(5), f(6)]; % Positon [x, y, z] m
V_rel = [V_g(1) - vWindx, V_g(2) - vWindy, V_g(3)]; % Relative wind speed [x, y, z] m/s

if norm(R) < 2 * 0.3048 % if the rocket hasn't left the 2 ft rails
    head = [cos(theta), 0, sin(theta)];
else
    head = V_rel/norm(V_rel); % Heading vector (direction of rocket)
end

D = rho_amb/2 * norm(V_rel)^2 * C_Dbottle * A_b * head; % N - Drag force

dRdt = V_g; % Vector of Ground Speed [x, y, z] m/s

F_g = [0, 0, -g * m_0];

if norm(R) < 2 * 0.3048 % if the rocket hasn't left the 2 ft rails
    dV_gdt = -D/m_0; % No gravity
else
    dV_gdt = (-D + F_g)/m_0; % Sum of forces divided by mass to get acceleration
end

% Once the rocket hits the ground, it should no longer travel in the x and
% z directions.
if R(3) <= 0 && t > 2
   dRdt = 0;
end

dfdt(1:3) = dV_gdt;
dfdt(4:6) = dRdt;
                                                                                         
end

