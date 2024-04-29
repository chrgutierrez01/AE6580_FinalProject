function [F, M, L, D] = getaeroforcesmoments(DCM,V_b_fps, Omega_b_dps, delvl_deg, delvr_deg, drud_deg, betad_deg, alphad_deg, rho_sl_ft3, mach, F_prop)


%% Constants
b = 60;
c = 80;
m = 300000;
S_ref = 3603;
g = [0 0 32.2];
g_b = m*DCM*g';

%% UNIT CORRECTIONS
%There might need to be unit corrections to the effector deflection angles.
p = Omega_b_dps(1);
q = Omega_b_dps(2);
r = Omega_b_dps(3);
beta = deg2rad(betad_deg);
alpha = deg2rad(alphad_deg);
V = norm(V_b_fps);

%% OBTAIN COEFFICIENTS                                       
[CLbv, CL_RE, CL_LE, CDbv, CD_RE, CD_LE, CD_RUD, CYB, CY_RE, CY_LE, ...
    CY_RUD, Cllbv, Cll_RE, Cll_LE, Cll_RUD, Cllr, Cllp, Cmbv, Cm_RE, ...
    Cm_LE, Cm_RUD, Cm_q, Cnbv, Cn_RE, Cn_LE, Cn_RUD, Cnp, Cnr] = getaerocoefficients(alpha, mach, delvl_deg, delvr_deg, drud_deg);

%% SUM TOTAL COEFFICIENTS
CL = CLbv + CL_RE + CL_LE;
CD = CDbv + CD_RE + CD_LE + CD_RUD;
CY = CYB*beta + CY_RE + CY_LE + CY_RUD;
%NEED TO ADD THE NONDIMENSIONAL PITCH ROLL AND YAW RATES ex. (r*b/(2*V))
Cl = Cllbv*beta + Cll_RE + Cll_LE + Cll_RUD + Cllr * (r*b/(2*V)) + Cllp * (p*b/(2*V))
Cm = Cmbv + Cm_RE + Cm_LE + Cm_RUD + Cm_q*(q*c/(2*V));
Cn = Cnbv*beta + Cn_RE + Cn_LE + Cn_RUD + Cnp*(p*b/(2*V)) + Cnr*(r*b/(2*V));

%% CALCULATE TOTAL FORCES
q_bar = 0.5*rho_sl_ft3*V;
L = q_bar*S_ref*CL;
D = q_bar*S_ref*CD;
Y = q_bar*S_ref*CY;
% What is the "b" after q_bar????
l = q_bar*b*S_ref*Cl;
m = q_bar*c*S_ref*Cm;
n = q_bar*b*S_ref*Cn;

%% ROTATE TO RIGHT FRAME
% This needs to be in the body frame (?) ensure the upstream is doing that
% right.
F = [-D*cos(alpha)+L*sin(alpha)+F_prop;Y;-D*sin(alpha)-L*cos(alpha)]+g_b;
M = [l;m;n];

end 