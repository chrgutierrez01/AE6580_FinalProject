%  %% XXX Control Laws v0.1
% % This top level page is used to build a set of Control Laws (CLAWs) for a vehicle. The
% % basic organization is as follows:
% % 
% % * |top_level_claw_init.m|:  Initialize environment, variables & internal buses used in the Simulink diagram
% % * |top_level_claw.slx|: The master Simulink diagram
% % * |busdef_claw_input.m|: Bus definition file for the CLAW Input interface
% % * |busdef_claw_output.m|: Bus definition file for the CLAW Output interface
% % * |./cfg|: location of model configuration set files
% % * |./doc|: location of documentation files
% % * |./claw|: location of any referenced subsystems if they exist
% % * |./lib|: location of custom libraries
% % * |./onboard_model|: location of onboard model code
% %
% %
% % clear all   % this causes problems with make_claw_release
% %
% %% Aircraft Specific Constants & Versioning
% % CLAW identification, frame rate, versioning, build-date, and MATLAB version checks are performed here. The 
% % CLAW version uses a MAJOR.MINOR.SAVE_COUNT version number. Major versions are scheduled official releases 
% % (Load 0, Load 1, etc..), minor versions are internal Piasecki modifications, and save_count is an automatic
% % Simulink save number to help differentiate internal work. When updating the major or minor version, the save
% % count shall be reset to zero using: 
% %    set_param('top_level_claw','ModelVersionFormat', sprintf('%d.%d.%%<AutoIncrement:1>',CLAW_INFO.version(1:2)))
% % The CLAW version is encoded as a 32-bit integer using 100000000 + 100000*MAJOR + 1000*MINOR + SAVE_COUNT.
% % MAJOR and MINOR must be <= 99 and SAVE_COUNT<=999. The version string can be reconstructed using :
% %    y=num2str(CLAW_INFO.version_int);sprintf('%d.%d.%d',[str2num(y(3:4)), str2num(y(5:6)), str2num(y(7:9))])
% % The build date is stored as a 32-bit integer as 'yyyymmmdd'.
% CLAW_INFO.bdname = 'top_level_claw'; % Name of the top level block diagram file
% CLAW_INFO.CLAW_ID = 'MY_CLAW_01'; % CLAW Identifier name
% CLAW_INFO.DOC_ID = '000-C-00-00-00'; % PiAC Document ID Number
% CLAW_VER_MAJOR = 0; % Remember to reset ModelVersionFormat when updating MAJOR or MINOR versions.
% CLAW_VER_MINOR = 0;
% t_step_sec = 0.01;          % sample time [sec]
% % The directories listed in .paths are added to %PATH% and are relative to the location of this file itself. 
% CLAW_INFO.paths.CLAW_DIR = '.\claw';  % location of referenced models used in top_level_claw.slx; default='claw'
% 
% v=ver('MATLAB');
% if v.Release == "(R2017a)"
%     CLAW_INFO.CLAW_REF_CONFIG = 'cfg\claw_ref_configuration_2017a.m';
% else
%     CLAW_INFO.CLAW_REF_CONFIG = 'cfg\claw_ref_configuration.m';
% %     CLAW_REF_CONFIG = 'cfg\claw_ref_configuration_dll.m';  % uncomment to make a DLL  - don't use this - see py_build directory
% end
% 
% 
% %% Initialize the Environment 
% % This section performs the environment initialization including setting
% % the path up to load dependent libraries, add the claw directory to the path,
% % and print a status banner.
% %
% global CLAW_TOP_LEVEL_DIR  LIB_DIR
% LIB_DIR = '.\lib'; % relative path of the lib_piac library
% LIB_PIAC = 'lib_piac'; % name of the lib_piac library file
% [CLAW_TOP_LEVEL_DIR,init_script_name]=fileparts(mfilename('fullpath')); % get the location of the model directory
% [~,AC_NAME] = fileparts(CLAW_TOP_LEVEL_DIR); % get the name of the aircraft these CLAWS are for
% addpath(fullfile(CLAW_TOP_LEVEL_DIR,LIB_DIR));  % Add LIB_DIR to the path
% load_system(fullfile(CLAW_TOP_LEVEL_DIR,LIB_DIR, LIB_PIAC)); % Load LIB_PIAC simulink model
% cellfun(@(p) addpath(fullfile(CLAW_TOP_LEVEL_DIR,p)), struct2cell(CLAW_INFO.paths)) % add directories in paths to PATH
% 
% run(fullfile(CLAW_TOP_LEVEL_DIR,CLAW_INFO.CLAW_REF_CONFIG)); % run code generation configuration
% 
% CLAW_VER_SAVECOUNT = NaN;
% if bdIsLoaded(CLAW_INFO.bdname)
%     CLAW_VER_SAVECOUNT = sscanf(get_param(CLAW_INFO.bdname,'ModelVersion'),'%*d.%*d.%d');
% end
% CLAW_INFO.version = [CLAW_VER_MAJOR,CLAW_VER_MINOR,CLAW_VER_SAVECOUNT];
% CLAW_INFO.version_int = int32(100000000 + CLAW_INFO.version*[100000;1000;1]);% encode version integer (10MMmmsss: MM.mm.sss) to avoid using a string constant in simulink
% CLAW_INFO.version_str = sprintf('%d.%d.%d',CLAW_INFO.version);
% CLAW_INFO.builddate_int = int32(str2num(datestr(now,'yyyymmdd'))); % store builddate in YYYYMMDD int32

% fprintf('\n================================== Init Environment ==================================\n')
% fprintf(' * %s *\n',strjust(sprintf('%80s',[AC_NAME '/' init_script_name]),'center'));
% fprintf(' * %80s *\n','');
% fprintf(' * %s *\n',strjust(sprintf('%80s',CLAW_INFO.CLAW_ID),'center'))
% fprintf(' * %s *\n',strjust(sprintf('%80s',sprintf(' %0.1f Hz rate',1/t_step_sec)),'center'))
% fprintf(' * %80s *\n','');
% fprintf(' * %s *\n',strjust(sprintf('%80s',CLAW_INFO.version_str),'center'))
% fprintf(' * %80s *\n','');
% fprintf(' * Base: %s *\n',strjust(sprintf('%74s',CLAW_TOP_LEVEL_DIR),'center'));
% fprintf(' * CLAW: %s *\n',strjust(sprintf('%74s',CLAW_INFO.paths.CLAW_DIR),'center'));
% fprintf(' * lib_piac v%s:  %s *\n',get_param('lib_piac','ModelVersion'),strjust(sprintf('%63s',which(LIB_PIAC)),'center'));
% fprintf('======================================================================================\n\n')

% try
%     % if the goto labels are updated when this script is called from another model, an error will be raised.
%     % Catch this error. Run this script directly to update goto labels.
%     display_goto_destinations('top_level_claw',true)
% catch
%     disp('Skipping goto label updates.')
% end

%% Constants
KCONST.G_fps2 = param_helper(32.174, 'Unit','ft/s/s','Description','acceleration due to gravity (ft/s^2)','DataType','double');
KCONST.R2D = param_helper(180.0/pi, 'Unit','','Description','convert radians to degree','DataType','double');
KCONST.D2R = param_helper(pi/180.0, 'Unit','','Description','convert degree to radian','DataType','double');
KCONST.KTS2FPS = param_helper(1852.0/(.3048*3600), 'Unit','','Description','convert kts to ft/s','DataType','double');
KCONST.FPS2KTS = param_helper((.3048*3600)/1852.0, 'Unit','','Description','convert ft/s to kts','DataType','double');
KCONST.INCH2FT = param_helper(1.0/12.0, 'Unit','','Description','convert inches to feet','DataType','double');
KCONST.P0_psf = param_helper(2116.22, 'Unit','lbf/ft^2','Description','sea level standard pressure','DataType','double');
KCONST.RHO0_slgft3 = param_helper(0.0023769, 'Unit','slug*ft^3', 'Description','Sea Level Standard Density','DataType','double');

%% Control Law Subsystem Parameters
% This section lists parameters used by each control law subsystem.
% Table Lookups
% Input Processing Parameters

%%CLU01

%%CLU02

%%CLU03
% Hover Mode
KCLU03.hov_phi_cmd_k_rad = param_helper(30*0.01745, 'Unit','rad','Description','Roll attitude command scale factor/limiter','DataType','double');
KCLU03.hov_theta_cmd_k_rad = param_helper(30*0.01745, 'Unit','rad','Description','Pitch attitude command scale factor/limiter','DataType','double');
KCLU03.hov_r_cmd_k_rps = param_helper(15*0.01745, 'Unit','rad','Description','Yaw rate command scale factor/limiter','DataType','double');
%KCLU02.hov_vz_cmd_k_fps = param_helper(13.91, 'Unit','fps','Description','Z-vel command scale factor/limiter','DataType','double');
KCLU03.hov_vz_cmd_min_fps = -10.5; %fps, Z-vel minimum in vertical
KCLU03.hov_vz_cmd_max_fps = 13.91; %fps, Z-vel maximum in vertical
KCLU03.hov_vz_cmd_range_fps = [KCLU03.hov_vz_cmd_min_fps,KCLU03.hov_vz_cmd_max_fps];
%Cruise Mode
KCLU03.fwd_phi_cmd_k_rad = param_helper(30*0.01745, 'Unit','rad','Description','Roll attitude command scale factor/limiter','DataType','double');
KCLU03.fwd_theta_cmd_k_rad = param_helper(30*0.01745, 'Unit','rad','Description','Pitch attitude command scale factor/limiter','DataType','double');
KCLU03.fwd_r_cmd_k_rps = param_helper(15*0.01745, 'Unit','rad','Description','Yaw rate command scale factor/limiter','DataType','double');
%KCLU02.fwd_vz_cmd_k_fps = param_helper(120*1.688, 'Unit','fps','Description','Z-vel command scale factor/limiter','DataType','double');
KCLU03.fwd_vz_cmd_min_fps =74*1.688; %fps, Z-vel maximum in fwd flight
KCLU03.fwd_vz_cmd_max_fps = 122*1.688; %fps, Z-vel maximum in fwd flight
KCLU03.fwd_vz_cmd_range_fps = [KCLU03.fwd_vz_cmd_min_fps,KCLU03.fwd_vz_cmd_max_fps];

%%CLS01
% Command Filtering Parameters
KCLS01.v2h_transition_quat = param_helper([1,0,0,0]','Unit','nd','Description','Desired horizontal(fwd) quaternion','DataType','double');
KCLS01.h2v_transition_quat = param_helper([0.7071,0,0.7071,0]','Unit','nd','Description','Desired vertical quaternion','DataType','double');

%%CLS02

%%CLM01
% Inner Loop Params (CHECK THAT THESE ARE BEING LOADED IN PROPERLY)
KCLM01.LQR_gains_hover = param_helper(load('lqr/SS_Models/Hover/LQR_gains.mat').K, 'Unit','multi','Description','LQR Gain Matrix for Hover','DataType','double');
KCLM01.LQR_gains_transition = param_helper(load('lqr/SS_Models/Transition/LQR_gains.mat').K, 'Unit','multi','Description','LQR Gain Matrix for Transition','DataType','double');
KCLM01.LQR_gains_cruise = param_helper(load('lqr/SS_Models/Cruise/LQR_gains.mat').K, 'Unit','multi','Description','LQR Gain Matrix for Cruise','DataType','double');

%%CLM02
% Mixer Parameters
KCLM02.lat_act_up = param_helper(8,'Unit','deg','Description','Lateral Actuator Upper Saturation','DataType','double');
KCLM02.lat_act_low = param_helper(-8,'Unit','deg','Description','Lateral Actuator Lower Saturation','DataType','double');
KCLM02.lon_act_up = param_helper(15,'Unit','deg','Description','Longitudinal Actuator Upper Saturation','DataType','double');
KCLM02.lon_act_low = param_helper(-12.5,'Unit','deg','Description','Longitudinal Actuator Lower Saturation','DataType','double');
KCLM02.col_act_up = param_helper(12,'Unit','deg','Description','Collective Actuator Upper Saturation','DataType','double');
KCLM02.col_act_low = param_helper(0,'Unit','deg','Description','Collective Actuator Lower Saturation','DataType','double');
KCLM02.fan_act_up = param_helper(1000,'Unit','rpm','Description','Fan Actuator Upper Saturation','DataType','double');
KCLM02.fan_act_low = param_helper(0,'Unit','rpm','Description','Fan Actuator Lower Saturation','DataType','double');
KCLM02.ail_act_up = param_helper(15,'Unit','deg','Description','Aileron Actuator Upper Saturation','DataType','double');
KCLM02.ail_act_low = param_helper(-15,'Unit','deg','Description','Aileron Actuator Lower Saturation','DataType','double');
KCLM02.elev_act_up = param_helper(20,'Unit','deg','Description','Elevator Actuator Upper Saturation','DataType','double');
KCLM02.elev_act_low = param_helper(-20,'Unit','deg','Description','Elevator Actuator Lower Saturation','DataType','double');
KCLM02.rud_act_up = param_helper(20,'Unit','deg','Description','Rudder Actuator Upper Saturation','DataType','double');
KCLM02.rud_act_low = param_helper(-20,'Unit','deg','Description','Rudder Actuator Lower Saturation','DataType','double');



% Output Subsystem if you change this scale factor matrix, you need to update the ICD!
CLOUTPUT.Bmat_scale = param_helper( 0.01*ones(5,5), 'DataType','double', 'Unit','', 'Description','Scaling matrix for B-matrix integer packing. Scales elements to range ~[-1,1].', 'Dimensions',[5 5]);

%% Enumerated Data Types

%% Checks
if bdIsLoaded(CLAW_INFO.bdname)
    mdl_ver_str_chk = sscanf(get_param(CLAW_INFO.bdname,'ModelVersion'),'%d.%d.%d');
    if ~all(mdl_ver_str_chk == sscanf(CLAW_INFO.version_str,'%d.%d.%d'))
        error("Init script version and ModelVersion do not agree.\n    CLAW_INFO.version_str = '%s'\n    ModelVersion          = '%s\n    ModelVersionFormat    = '%s'\nSee Comment by CLAW_INFO.version_str to fix.",CLAW_INFO.version_str,get_param(CLAW_INFO.bdname,'ModelVersion'),get_param(CLAW_INFO.bdname,'ModelVersionFormat'))
    end
end



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

busdef_claw_input;

busdef_claw_output;


%% Internal Interface Buses
%%CL6_PLANT
bus_helper(struct('BusName','B_CL6_Plant','HeaderFile','','Desc','CL6 Plant Simulation','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','vnorth_state_fps',      'DataType','double',  'Unit','ft/s', 'Description','selected north speed'};
            {'ElementName','veast_state_fps',      'DataType','double',  'Unit','ft/s', 'Description','selected east speed'};
            {'ElementName','vup_state_fps',      'DataType','double',  'Unit','ft/s', 'Description','selected north speed'};
            {'ElementName','xnorth_state_ft',    'DataType','double',  'Unit','ft', 'Description','selected north direction position'};
            {'ElementName','xeast_state_ft',     'DataType','double',  'Unit','ft',  'Description','selected east direction position'};
            {'ElementName','xup_state_ft',     'DataType','double',  'Unit','ft',  'Description','selected up direction position'};
            {'ElementName','phi_state_rad',  'DataType','double',  'Unit','rad', 'Description','selected euler angle phi'};
            {'ElementName','theta_state_rad',  'DataType','double',  'Unit','rad', 'Description','selected euler angle theta'};
            {'ElementName','psi_state_rad', 'DataType','double',  'Unit','rad', 'Description','selected euler angle psi'};
            {'ElementName','R_NEDtoB', 'DataType','double',  'Unit','nd',    'Description','Rotation Matrix NED to Body','Dimensions',[3,3]};
            {'ElementName','pb_state_rps',       'DataType','double',  'Unit','rps',    'Description','selected body roll rate','Dimensions',[3,3]};    
            {'ElementName','qb_state_rps',         'DataType','double',  'Unit','rps',   'Description','selected body pitch rate'};
            {'ElementName','rb_state_rps', 'DataType','double',  'Unit','rps',   'Description','selected body yaw rate'};
            {'ElementName','pbdot_sel_rps2',       'DataType','double',  'Unit','rps2',   'Description','selected pbdot'};
            {'ElementName','qbdot_sel_rps2',       'DataType','double',  'Unit','rps2',   'Description','selected qbdot'};
            {'ElementName','rbdot_sel_rps2',       'DataType','double',  'Unit','rps2',   'Description','selected rbdot'};
            {'ElementName','axbdot_sel_fps2',       'DataType','double',  'Unit','fps2',   'Description','selected body x acceleration'};
            {'ElementName','aybdot_sel_fps2',       'DataType','double',  'Unit','fps2',   'Description','selected body y acceleration'};
            {'ElementName','azbdot_sel_fps2',       'DataType','double',  'Unit','fps2',   'Description','selected body z acceleration'};
           });
%%CLU02       
bus_helper(struct('BusName','B_CLU02_AutonomousModeSwitch','HeaderFile','','Desc','CLU02 Autonomous Mode Switch Output Bus','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','FlightMode',      'DataType','double',  'Unit','nd', 'Description','Current flight mode [1.Fwd, 2.Hov, 3.V2H, 4.H2V'};
            {'ElementName','transition_flag',      'DataType','boolean',  'Unit','nd', 'Description','Indicates if transition is in progress'};
           });
%%CLU03       
bus_helper(struct('BusName','B_CLU03_InpCmdPrc_FLSIM','HeaderFile','','Desc','CLU03 Input Pilot Command Processing Output Bus','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','lat_cmd_lim_rad',      'DataType','double',  'Unit','rad', 'Description','Lateral stick limited/conditioned input [-max roll, max roll]'};
            {'ElementName','lon_cmd_lim_rad',      'DataType','double',  'Unit','rad', 'Description','Longitudinal stick limited/conditioned input [-max pitch, max pitch]'};
            {'ElementName','ped_cmd_lim_rps',      'DataType','double',  'Unit','rps', 'Description','Yaw-axis pedal limited/conditioned input [-max yaw rate, max yaw rate]'};
            {'ElementName','col_cmd_lim_fps',      'DataType','double',  'Unit','fps', 'Description','Collective stick limited/conditioned input [-min Z-vel, max Z-vel]'};
           });
%%CLS01
bus_helper(struct('BusName','B_CLS01_DesiredQuaternion','HeaderFile','','Desc','CLS01 Desired Quaternion Determination Output Bus','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','quat_cmd',      'DataType','double',  'Unit','nd', 'Description','Desired Quaternion Command'};
           });

%%CLS02
bus_helper(struct('BusName','B_CLS02_AttitudeController','HeaderFile','','Desc','CLS02 Attitude Controller Output Bus','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','p_cmd_rps',  'DataType','double', 'Unit','rps', 'Description','commanded roll rate'};
            {'ElementName','q_cmd_rps',  'DataType','double', 'Unit','rps', 'Description','commanded pitch rate'};
            {'ElementName','r_cmd_rps',  'DataType','double', 'Unit','rps', 'Description','commanded yaw rate'};
            });      
%%CLM01
bus_helper(struct('BusName','B_CLM01_INNERLOOP_LQR_FLSIM','HeaderFile','','Desc','CLM01 Inner Loop LQR Output Bus','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','lat_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','commanded main rotor lateral angle'};
            {'ElementName','lon_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','commanded main rotor long angle'};
            {'ElementName','col_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','commanded main rotor collective angle'};
            {'ElementName','fan_act_cmd_rpm',  'DataType','double', 'Unit','rpm', 'Description','commanded tip fan rpm'};
            {'ElementName','stbdail_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','commanded stbd aileron deflection angle'};
            {'ElementName','portail_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','commanded port aileron deflection angle'};
            {'ElementName','elev_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','commanded elevator actuator angle'};
            {'ElementName','rud_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','commanded rudder actuator angle'};
            });       
        
%%CLM02
bus_helper(struct('BusName','B_CLM02_ActuatorSaturator','HeaderFile','','Desc','CLM02 Actuator Saturator Output Bus','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','lat_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','saturated main rotor lateral angle'};
            {'ElementName','lon_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','saturated main rotor long angle'};
            {'ElementName','col_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','saturated main rotor collective angle'};
            {'ElementName','fan_act_cmd_rpm',  'DataType','double', 'Unit','rpm', 'Description','saturated tip fan rpm'};
            {'ElementName','stbdail_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','saturated stbd aileron deflection angle'};
            {'ElementName','portail_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','saturated port aileron deflection angle'};
            {'ElementName','elev_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','saturated elevator actuator angle'};
            {'ElementName','rud_act_cmd_rad',  'DataType','double', 'Unit','rad', 'Description','saturated rudder actuator angle'};
            });    
  
%% Control Law Diagrams

.