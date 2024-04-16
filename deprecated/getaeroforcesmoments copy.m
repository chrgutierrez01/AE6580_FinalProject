%Function that generates aero forces and moments using aero coefficient
%data. 
function [ fnormb_lb, faxialb_lb, fsideb_lb, mpitchb_ftlb, lrollb_ftlb, nyawb_ftlb ] = getaeroforcesmoments(rho_sl_ft3, vtrue_fps, alphad_deg, betad_deg,...
                                           delvl_deg, delvr_deg, drud_deg, ...
                                           pb_dps, qb_dps, rb_dps)
      
%% Constants
b = 60;
c = 80;
S_ref = 3603;

%% UNIT CORRECTIONS
%There might need to be unit corrections to the effector deflection angles.
p = deg2rad(pb_dps);
q = deg2rad(qb_dps);
r = deg2rad(rb_dps);
beta = deg2rad(betad_deg);
alpha = deg2rad(alphad_deg);
V = vtrue_fps;

%% OBTAIN COEFFICIENTS                                       
[CLbv, CL_RE, CL_LE, CDbv, CD_RE, CD_LE, CD_RUD, CYB, CY_RE, CY_LE, ...
    CY_RUD, Cllbv, Cll_RE, Cll_LE, Cll_RUD, Cllr, Cllp, Cmbv, Cm_RE, ...
    Cm_LE, Cm_RUD, Cm_q, Cnbv, Cn_RE, Cn_LE, Cn_RUD, Cnp, Cnr] = getaerocoefficients(alpha, mach, delvl_deg, delvr_deg, drud_deg);

%% SUM TOTAL COEFFICIENTS
CL = CLbv + CL_RE + CL_LE;
CD = CDbv + CD_RE + CD_LE + CD_RUD;
CY = CYB*beta + CY_RE + CY_LE + CY_RUD;
%NEED TO ADD THE NONDIMENSIONAL PITCH ROLL AND YAW RATES ex. (r*b/(2*V))
Cl = Cllbv*beta + Cll_RE + Cll_LE + Cll_RUD + Cllr * (r*b/(2*V)) + Cllp * (p*b/(2*V));
Cm = Cmbv + Cm_RE + Cm_LE + Cm_RUD + Cm_q*(q*c/(2*V));
Cn = Cnbv*beta + Cn_RE + Cn_LE + Cn_RUD + Cnp*(p*b/(2*V)) + Cnr*(r*b/(2*V));

%% CALCULATE TOTAL FORCES
q_bar = 0.5*rho_sl_ft3*V;
L = q_bar*S_ref*CL;
D = q_bar*S_ref*CD;
Y = q_bar*S_red*CY;
% What is the "b" after q_bar????
l = q_bar*b*S_ref*Cl;
m = q_bar*c*S_ref*Cm;
n = q_bar*b*S_ref*Cn;

%% ROTATE TO RIGHT FRAME
% This needs to be in the body frame (?) ensure the upstream is doing that
% right.
fnormb_lb = -D*sin(alpha)-L*cos(alpha);
faxialb_lb = -D*cos(alpha)+L*sin(alpha);
fsideb_lb = Y;
mpitchb_ftlb = m;
lrollb_ftlb = l;
nyawb_ftlb = n;

end 