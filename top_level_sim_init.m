%% GHV NDI Control Laws V0.1
% Initializes variables required to run the top_level_sim.slx simulation.
% This script is called at t=0 before the initial propagation.

addpath("lib/");

%% Simulator Setup - Constants
%%Initial Conditions

% Initial Environment
S_rho_ic_slft3 = 0.0023769;

% Initial Bmat
% Look into calculating this instead of hard setting it
CL04_Bmat0_ic = [1.059	0	0.02663	0.000107333362393547;...
    0 -112.6 45.03 0;...
    32.36 0 0 0;...
    0 1.824 -20.75 0];


% Initial Position
S_xi0_ic_ft = 0;
S_yi0_ic_ft = 0;
S_zi0_ic_ft = -200;

% Initial Velocity
S_ub0_ic_fps = 6000;
S_vb0_ic_fps = 0;
S_wb0_ic_fps = 0;

% Initial AoA, SS
S_alphad0_ic_deg = rad2deg(atan2(S_wb0_ic_fps,S_ub0_ic_fps));
S_betad0_ic_deg = rad2deg(asin(S_vb0_ic_fps/norm([S_ub0_ic_fps,S_vb0_ic_fps, S_wb0_ic_fps])));

% Initial Euler Orientation
S_phi0_ic_rad = 0;
S_theta0_ic_rad = pi/60;
S_psi0_ic_rad = 0;


% Initial Body Rotation Rates
S_pb0_ic_rps = 0;
S_qb0_ic_rps = 0;
S_rb0_ic_rps = 0;
S_pb0_ic_dps = rad2deg(S_pb0_ic_rps);
S_qb0_ic_dps = rad2deg(S_qb0_ic_rps);
S_rb0_ic_dps = rad2deg(S_rb0_ic_rps);

% Initial Mass Properties
S_mass0_ic_lbs = 300000;
S_Ixx_ic_slf2 = 10^6;
S_Iyy_ic_slf2 = 10^7;
S_Izz_ic_slf2 = 10^7;
S_Ixy_ic_slf2 = 0;
S_Iyz_ic_slf2 = 0;
S_Izx_ic_slf2 = 0;

% Initial Deflections & Inputs
S_symelv_ic_deg = 0;
S_difelv_ic_deg = 0;
S_drud_ic_deg = 0;
S_fprop_ic_lbf = 0;

% Deflection Range
S_elev_rngdn_deg = -20;
S_elev_rngup_deg = 20;
S_rud_rngup_deg = 20;
S_rud_rngdn_deg = -20;


%% Simulator Setup
%%Percent Errors - Used for testing robustness of the controller. Will
%%change the values used in the controller vs those in the sim model.
%%
%%Example: pe = 0.1 then the resepective parameter will be set to 
%%param = (1.1)*actual_param

perr_mass = 0; %mass percent error
perr_Ixx = 0; %mass percent error
perr_Iyy = 0; %mass percent error
perr_Izz = 0; %mass percent error


%%Gains
%CL03_InnerLoopRegulator
cl03_roll_kp = 2.5;
cl03_roll_ki = 0;

cl03_pitch_kp = 4;
cl03_pitch_ki = 6;
cl03_pitch_kd = 0;

cl03_yaw_kp = 2;
cl03_yaw_ki = 4;

cl03_as_kp = 0.5;
cl03_as_ki = 0;
cl03_as_kd = 0;

cl03_climb_kp = 0;
cl03_climb_ki = 0;

%%Switch
%CL05_EffBLend
cl05_clawswitch = 1; %0 for off, 1 for on
cl05_INDIswitch = 1; %0 for NDI, 1 for INDI

%% Control Law Input/Output Buses  
% These are autocoded using the ICD spreadsheets and icd_autocoder 
%
% This is the definition for the CLAW Input BUS:
%
% <include>busdef_claw_input.m</include>
%
% This is the definition for the CLAW Output BUS:
%
% <include>busdef_claw_output.m</include>
%

%% Internal Interface Buses
%%S01_SimConfig
bus_helper(struct('BusName','B_S01_SimConfig','HeaderFile','','Desc','S01 Sim Configuration','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','mass_lbs','DataType','double',  'Unit','lbs', 'Description','vehicle mass'};
            {'ElementName','Ixx_slft2','DataType','double',  'Unit','slft2', 'Description','vehicle inertia - XX'};
            {'ElementName','Iyy_slft2','DataType','double',  'Unit','slft2', 'Description','vehicle inertia - YY'};
            {'ElementName','Izz_slft2','DataType','double',  'Unit','slft2', 'Description','vehicle inertia - ZZ'};
            {'ElementName','Ixy_slft2','DataType','double',  'Unit','slft2', 'Description','vehicle cross inertia - XY'};
            {'ElementName','Iyz_slft2','DataType','double',  'Unit','slft2', 'Description','vehicle cross inertia - YZ'};
            {'ElementName','Izx_slft2','DataType','double',  'Unit','slft2', 'Description','vehicle cross inertia - ZX'};
           });
%%S02_PLANT
bus_helper(struct('BusName','B_S02_Plant','HeaderFile','','Desc','S02 Plant Simulation','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','alphad_state_deg',       'DataType','double',  'Unit','deg',   'Description','selected angle of attack'};
            {'ElementName','betad_state_deg',       'DataType','double',  'Unit','deg',   'Description','selected angle of sideslip'};
            {'ElementName','delvl_state_deg',       'DataType','double',  'Unit','deg',   'Description','left elevon deflection in degrees'};
            {'ElementName','delvr_state_deg',       'DataType','double',  'Unit','deg',   'Description','right elevon deflection in degrees'};
            {'ElementName','drud_state_deg',       'DataType','double',  'Unit','deg',   'Description','rudder deflection in degrees'};
            {'ElementName','fprop_state_lbs',       'DataType','double',  'Unit','lbf',   'Description','prop thrust in lbf'};{'ElementName','vnorth_state_fps','DataType','double',  'Unit','ft/s', 'Description','selected north speed'};
            {'ElementName','veast_state_fps','DataType','double',  'Unit','ft/s', 'Description','selected east speed'};
            {'ElementName','vup_state_fps','DataType','double',  'Unit','ft/s', 'Description','selected north speed'};
            {'ElementName','xnorth_state_ft','DataType','double',  'Unit','ft', 'Description','selected north direction position'};
            {'ElementName','xeast_state_ft','DataType','double',  'Unit','ft',  'Description','selected east direction position'};
            {'ElementName','xup_state_ft','DataType','double',  'Unit','ft',  'Description','selected up direction position'};
            {'ElementName','phi_state_rad','DataType','double',  'Unit','rad', 'Description','selected euler angle phi'};
            {'ElementName','theta_state_rad','DataType','double',  'Unit','rad', 'Description','selected euler angle theta'};
            {'ElementName','psi_state_rad','DataType','double',  'Unit','rad', 'Description','selected euler angle psi'};
            {'ElementName','R_NEDtoB','DataType','double',  'Unit','nd',    'Description','Rotation Matrix NED to Body','Dimensions',[3,3]}           
            {'ElementName','ub_state_fps',       'DataType','double',  'Unit','fps',   'Description','selected body x velocity'};
            {'ElementName','vb_state_fps',       'DataType','double',  'Unit','fps',   'Description','selected body y velocity'};
            {'ElementName','wb_state_fps',       'DataType','double',  'Unit','fps',   'Description','selected body z velocity'};
            {'ElementName','pb_state_rps',       'DataType','double',  'Unit','rps',    'Description','selected body roll rate'};
            {'ElementName','qb_state_rps',         'DataType','double',  'Unit','rps',   'Description','selected body pitch rate'};
            {'ElementName','rb_state_rps', 'DataType','double',  'Unit','rps',   'Description','selected body yaw rate'};
            {'ElementName','pbdot_state_rps2',       'DataType','double',  'Unit','rps2',   'Description','selected pbdot'};
            {'ElementName','qbdot_state_rps2',       'DataType','double',  'Unit','rps2',   'Description','selected qbdot'};
            {'ElementName','rbdot_state_rps2',       'DataType','double',  'Unit','rps2',   'Description','selected rbdot'};
            {'ElementName','axbdot_state_fps2',       'DataType','double',  'Unit','fps2',   'Description','selected body x acceleration'};
            {'ElementName','aybdot_state_fps2',       'DataType','double',  'Unit','fps2',   'Description','selected body y acceleration'};
            {'ElementName','azbdot_state_fps2',       'DataType','double',  'Unit','fps2',   'Description','selected body z acceleration'};
            {'ElementName','mach_state_nd',       'DataType','double',  'Unit','nd',   'Description','mach number'};
            {'ElementName','pb_state_dps',       'DataType','double',  'Unit','dps',    'Description','selected body roll rate'};
            {'ElementName','qb_state_dps',         'DataType','double',  'Unit','dps',   'Description','selected body pitch rate'};
            {'ElementName','rb_state_dps', 'DataType','double',  'Unit','dps',   'Description','selected body yaw rate'};
           });

%%CL01_CommandProcessing
bus_helper(struct('BusName','B_CL01_ComProc','HeaderFile','','Desc','CL01 Command Processing','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','pb_cmd_dps','DataType','double',  'Unit','dps', 'Description','roll rate command in degrees'};
            {'ElementName','qb_cmd_dps','DataType','double',  'Unit','dps', 'Description','pitch rate command in degrees'};
            {'ElementName','rb_cmd_dps','DataType','double',  'Unit','dps', 'Description','yaw rate command in degrees'};
            {'ElementName','as_cmd_fps','DataType','double',  'Unit','fps', 'Description','axial speed command in fps'};
            {'ElementName','climb_cmd_fps','DataType','double',  'Unit','fps', 'Description','climb command in fps'};
           });

%%CL02_InputProcessing
bus_helper(struct('BusName','B_CL02_InputProcessing','HeaderFile','','Desc','CL02 Input Processing','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','vtot_i_proc_fps','DataType','double',  'Unit','ft/s', 'Description','calculated total speed'};
            {'ElementName','aos_i_proc_deg','DataType','double',  'Unit','deg', 'Description','calculated angle of sideslip'};
            {'ElementName','aoa_i_proc_deg','DataType','double',  'Unit','deg', 'Description','calculated angle of attack'};
           });

%%CL03_InnerLoopRegulator
bus_helper(struct('BusName','B_CL03_InnerLoop','HeaderFile','','Desc','CL03 Inner Loop Regulator','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','roll_cmd_dps2','DataType','double',  'Unit','dps2', 'Description','roll acceleration command in degrees'};
            {'ElementName','pitch_cmd_dps2','DataType','double',  'Unit','dps2', 'Description','pitch acceleration command in degrees'};
            {'ElementName','yaw_cmd_dps2','DataType','double',  'Unit','dps2', 'Description','yaw acceleration command in degrees'};
            {'ElementName','as_cmd_fps2','DataType','double',  'Unit','fps2', 'Description','axial acceleration command in feet'};
            {'ElementName','climb_cmd_fps2','DataType','double',  'Unit','fps2', 'Description','climb acceleration command in feet'};
           });

%%CL04_NDI
bus_helper(struct('BusName','B_CL04_NDI','HeaderFile','','Desc','CL04 NDI Module','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','u_state_obm_fps2','DataType','single',  'Unit','fps2', 'Description','axial acceleration calculated in feet'};
            {'ElementName','v_state_obm_fps2','DataType','single',  'Unit','fps2', 'Description','lateral acceleration calculated in feet'};
            {'ElementName','w_state_obm_fps2','DataType','single',  'Unit','fps2', 'Description','climb acceleration calculated in feet'};
            {'ElementName','roll_state_obm_dps2','DataType','single',  'Unit','dps2', 'Description','roll acceleration calculated in degrees'};
            {'ElementName','pitch_state_obm_dps2','DataType','single',  'Unit','dps2', 'Description','pitch acceleration calculated in degrees'};
            {'ElementName','yaw_state_obm_dps2','DataType','single',  'Unit','dps2', 'Description','yaw acceleration calculated in degrees'};
            {'ElementName','Bmat_obm','DataType','double',  'Unit','nd',    'Description','Rotation Matrix NED to Body','Dimensions',[4,4]} 
            {'ElementName','symelv_state_deg','DataType','single',  'Unit','deg',    'Description','Symmetric Elevon Command in Degrees'} 
            {'ElementName','difelv_state_deg','DataType','single',  'Unit','deg',    'Description','Differential Elevon Command in Degrees'} 
            {'ElementName','drud_state_deg','DataType','single',  'Unit','deg',    'Description','Rudder Command in Degrees'} 
            {'ElementName','fprop_state_lbf','DataType','single',  'Unit','lbf',    'Description','Forward Prop Command in lbs'}
           });

%%CL05_EffectorBlender
bus_helper(struct('BusName','B_CL05_EffBlend','HeaderFile','','Desc','CL05 Effector Blender','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','symelv_cmd_deg','DataType','double',  'Unit','deg', 'Description','left elevon deflection in degrees'};
            {'ElementName','difelv_cmd_deg','DataType','double',  'Unit','deg', 'Description','right elevon deflection in degrees'};
            {'ElementName','drud_cmd_deg','DataType','double',  'Unit','deg', 'Description','rudder deflection in degrees'}
            {'ElementName','fprop_cmd_lbf','DataType','double',  'Unit','lbf', 'Description','thrust command in lbf'}
           });

