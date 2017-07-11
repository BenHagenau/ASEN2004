function [ dfdt ] = pieceWiseODE( t, f )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The ode for the trajectory of a rocket, changes with based on the volume
% of water and air in the bottle at a given time. 
%
%
% Created: 4/25/17 - Connor Ott
% Last Modified: 4/26/17 - Connor Ott
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fetching all the little constants
global C_disch rho_amb vol_b P_atm gamma rho_W D_tht D_b R M_b C_drg P_gage ...
    vol_wi T_ai g vol_ai P_AbsAir M_ai M_wi vWindx vWindy thrust check

% Cross sectional areas
A_t = pi * (D_tht)^2 / 4; % Throat of bottle
A_b = pi * (0.0560832)^2 ; % m^2

% These are the current conditions of the rocket, ode45 utilizes these when
% integrating numerically.

V_g = [f(1), f(2), f(3)]; % Ground Speed [x, y, z] m/s
pos = [f(4), f(5), f(6)]; % Positon [x, y, z] m
V_rel = [V_g(1) - vWindx, V_g(2) - vWindy, V_g(3)]; % Relative wind speed [x, y, z] m/s

theta = f(7);
mass_a = f(8);
vol_a = f(9);
mass_R = f(10);

if V_g(2) ~= 0
   flag = 1; 
end

if norm(pos) < 2 * 0.3048 % if the rocket hasn't left the 2 ft rails
    head = [cos(theta), 0, sin(theta)];
    F_g = [0, 0, 0];
elseif norm(pos) >= 2 * 0.3048
    head = V_rel/norm(V_rel); % Heading vector (direction of rocket)
    F_g = [0, 0, -g * mass_R];
end


%% Dividing the ODE into stages
% There are 3 distinct phases in the flight of the bottle rocket, 
%   1. Before the water in the bottle is exhausted
%   2. After the water is exhausted, but compressed air is still in the
%   bottle
%   3. Ballistic phase, no more lift is generated and pressure inside the
%   bottle has equalized to atmospheric pressure.

%% New section

% Defining Pressure based on phase to begin so that the if statement can
% evaluate based on P.
if vol_a < vol_b
    P = P_AbsAir * (vol_ai/vol_a)^gamma;
else
    P_end = P_AbsAir * (vol_ai/vol_b)^gamma;
    P = P_end * (mass_a/M_ai)^gamma;
end



if vol_a < vol_b 
    %% Before Water is Exhausted
    % In this portion, the expulsion of water is the source of thrust for
    % the rocket
    
    P = P_AbsAir * (vol_ai/vol_a)^gamma;
    F = 2 * C_disch * (P - P_atm) * A_t * head; % N - Thrust force
    dmdt = -C_disch * A_t * sqrt(2 * rho_W * (P - P_atm)); % Change in mass with respect to time
    dvdt = C_disch * A_t * sqrt(2/rho_W  * (P_AbsAir * (vol_ai/vol_a)...
        ^gamma - P_atm)); % Change in volume with respect to time.
    dM_adt = 0; % Mass of air in bottle is not changing.
    
    stage = 'water';

elseif P > P_atm 
    %% After Water Is Exhausted
    % At this point, the thrust, and subsequently the velocity, of the
    % rocket is dependant on the expulsion of air in the bottle, rather
    % than water. 
    
    [V_ext, P_ext, T_ext, rho_ext, Mach_ext] = deal(-1); % Initializing
    
    P_crit = P * (2/(gamma + 1))^(gamma/(gamma - 1)); % Defining critical pressure
    rho = mass_a / vol_b;
    T = P / (rho * R);
    
    % Stipulations for the flow of air out of the bottle after the water is
    % exhausted
    if P_crit > P_atm % flow is choked, cahnges exit velocity of air in bottle
        
        % Referencing equations from Project 2 description
        P_ext = P_crit; % eq. 18
        T_ext = (2/(gamma + 1)) * T; % eq. 18
        V_ext = sqrt(gamma * R * T_ext);
        rho_ext = P_ext / (R * T_ext); % eq. 18
        
    elseif P_crit <= P_atm % flow is not choked
        
        P_ext = P_atm; % eq. 19
        Mach_ext = (((P/P_atm)^(1 - 1/gamma) - 1) * 2 / (gamma - 1))^(1/2);
        T_ext = T * (1 + (gamma - 1)/2 * Mach_ext^2);
        rho_ext = P_atm/(R * T_ext);
        V_ext = Mach_ext * sqrt(gamma * R * T_ext);
        
    end
    header = head;
    dM_adt = -C_disch * rho_ext * A_t * V_ext;
    dmdt = dM_adt;
    F = (-dM_adt * V_ext + (P_ext - P_atm) * A_t) .* header; % N - Thrust force
    dvdt = 0;
    stage = 'air';


else
    %% Balistic phase
    % Everything that could be expelled has been expelled, the rocket is
    % now a projectile affected only by gravity and drag
   
    F = 0 * head; % N - Thrust is now 0, all water and air are exhausted
    dmdt = 0; % Mass of rocket remains constant
    dM_adt = 0; % Mass of air remains constant
    dvdt = 0; % Volume of air remains constant
    stage = 'ballistic';

end
%% Everything else
% The following values have constant definitions during all phases of 
% flight, and thus can be defined outside the if statement. 

D = rho_amb/2 * norm(V_rel)^2 * C_drg * A_b * head; % N - Drag force
dV_gdt = (F - D + F_g)/mass_R; % Change in velocity with respect to time

if dV_gdt(2) ~= 0
   flag = 1; 
end


dPosdt = V_g;

if norm(V_g) < 1 % Accounting for miniscule (V << 1) velocities which could drastically increase dThetadt
    dThetadt = 0;
else
    dThetadt = -g * cos(theta)/(norm(V_g));
end

% Once the rocket hits the ground, it should no longer travel in the x and
% z directions.
if pos(3) <= 0 && t > 2
   dPosdt = [0, 0, 0];
end


% Final output
dfdt = [dV_gdt(1); dV_gdt(2); dV_gdt(3); dPosdt(1); dPosdt(2); dPosdt(3); dThetadt; dM_adt; dvdt; dmdt];

%store thrust
if check == 1
    thrust = [thrust; t norm(F)];
end
end

