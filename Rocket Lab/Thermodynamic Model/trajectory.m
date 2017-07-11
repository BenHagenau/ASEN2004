%Bottle Rocket Lab
%ASEN 2004
%Auther: Benjamin Hagenau
%Created: 3/15/17

%PURPOSE: The purpose of this file is to define the differential equations
%that are solved by ODE45 to describe the rockets trajectory.
%INPUT: Time parameter and initial conditions
%OUTPUT: Differential equations for parameters tracked by ode45
%ASSUMPTIONS:Isentropic fluid expansion, initial temperature of air is in
%equilibrium with STP


function [out] = trajectory(t,y)

global thrust conf Cd rho_a volume_rocket pa rho_water...
    At A R C p0 v0 m0 T

%define iterated values
VOL   = y(1);
Vx    = y(2);
Vy    = y(3);
Vz    = y(4);
X     = y(5);
Y     = y(6);
Z     = y(7);
M     = y(8);
MAIR  = y(9); 

g = conf.g;
Vwind = conf.wind;

%define rail limitations (do not use heading vector while on rails) and define heading vector. 
if norm([X,Y,Z]) < 2*0.3048 %[m]
    g = [0 0 0];
    Vwind = [0 0 0];
end

%define heading vector
Vrel = [Vx - Vwind(1),Vy - Vwind(2),Vz - Vwind(3)]; %define relative wind speed
h = Vrel./norm(Vrel); %define heading vector

if Z > 0 
%define pressure (II)
    p = (p0*(v0/volume_rocket)^1.4)*(MAIR/m0)^1.4;

%%%%%%%%%%%%%%%%%%%%%%STAGE I: WATER AND AIR IN BOTTLE%%%%%%%%%%%%%%%%%%%%%
    if VOL < volume_rocket
%determine pressure (I)
        p = p0*(v0/VOL)^1.4; 
%DEFINE FORCES
        Thrust = ((2*Cd*(p - pa)*At))*h;
        D = ((rho_a/2)*(norm(Vrel))^2*C*A)*h;
        Fx = Thrust(1) - D(1); Fy = Thrust(2) - D(2); Fz = Thrust(3) - D(3) - g(3)*M;
%DEFINE DIFFERENTIAL EQUATIONS (I)
        dVxdt        = Fx/M;
        dVydt        = Fy/M;
        dVzdt        = Fz/M;
        dVOLUMEAIRdt = Cd*At*sqrt((2*(p - pa)/rho_water));
        dMdt         = -(Cd*At)*sqrt(2*1000*(p - pa));
        dMAIRdt      = 0;
        dXdt         = Vx;
        dYdt         = Vy;
        dZdt         = Vz;
    
%%%%%%%%%%%%%%%%%%%%%%%STAGE II: WATER EXHAUSTED%%%%%%%%%%%%%%%%%%%%%%%%%%%
%determine stage 2 pressure
    elseif p > pa
%determine density of air
      rho = (MAIR)/volume_rocket; %[kg/m^3] 
%determine temperature of air 
      T = p/(rho*R); %[K] 
%define critical pressure
      cp = p*(2/2.4)^(1.4/.4); %[Pa]
%CHOKED FLOW
        if cp > pa
            T_exit = T*(2/2.4); 
            v_exit = sqrt(1.4*R*T_exit);
            rho_exit = cp/(R*T_exit);
        end 
%NOT CHOKED FLOW
        if cp <= pa
            MACH = sqrt(((p/pa)^(.4/1.4) - 1)*(2/.4));
            T_exit = T*(1+(.4/2)*MACH^2);
            v_exit = MACH*sqrt(1.4*R*T_exit);
            rho_exit = pa/(R*T_exit);
        end
%define pressure at the exit
        p_exit = rho_exit*R*T_exit;
%DEFINE FORCES
        Thrust = Cd*rho_exit*At*v_exit^2 + At*(p_exit - pa)*h;
        D = ((rho_a/2)*(norm(Vrel))^2*C*A)*h;
        Fx = Thrust(1) - D(1); Fy = Thrust(2) - D(2); Fz = Thrust(3) - D(3) - g(3)*M;
%DEFINE DIFFERENTIAL EQUATIONS (II)
        dVxdt        = Fx/M;
        dVydt        = Fy/M;
        dVzdt        = Fz/M;
        dVOLUMEAIRdt = 0;
        dMdt         = -Cd*rho_exit*At*v_exit;
        dMAIRdt      = -Cd*rho_exit*At*v_exit; 
        dXdt         = Vx;
        dYdt         = Vy;
        dZdt         = Vz;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%STAGE III: BALLISTIC%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        %DEFINE FORCES
        Thrust = 0*h;
        D = ((rho_a/2)*(norm(Vrel))^2*C*A)*h;
        Fx = Thrust(1) - D(1); Fy = Thrust(2) - D(2); Fz = Thrust(3) - D(3) - g(3)*M;
        
        dVxdt = Fx/M;
        dVydt = Fy/M;
        dVzdt = Fz/M;
        dVOLUMEAIRdt = 0;
        dMdt         = 0;
        dMAIRdt      = 0;
        dXdt         = Vx;
        dYdt         = Vy;
        dZdt         = Vz;
    end
else
%DEFINE DIFFERENTIAL EQUATIONS (after the rocket hits the ground)
    dVxdt = 0;
    dVydt = 0;
    dVzdt = 0;
    dVOLUMEAIRdt = 0;
    dMdt         = 0;
    dMAIRdt      = 0;
    dXdt         = 0;
    dYdt         = 0;
    dZdt         = 0;
    Thrust       = 0*h;
end

%create output for ode45
out(1) = dVOLUMEAIRdt;
out(2) = dVxdt;
out(3) = dVydt;
out(4) = dVzdt;
out(5) = dXdt;
out(6) = dYdt;
out(7) = dZdt;
out(8) = dMdt;
out(9) = dMAIRdt;

out = out';

%define thrust
thrust = [thrust; t Thrust];

end

