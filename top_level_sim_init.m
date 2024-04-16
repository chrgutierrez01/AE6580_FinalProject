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
%%Initial Conditions

% Initial Position
S_xi0_ic_ft = 0;
S_yi0_ic_ft = 0;
S_zi0_ic_ft = -200;

% Initial Velocity
S_ub0_ic_fps = 1000;
S_vb0_ic_fps = 0;
S_wb0_ic_fps = 0;

% Initial Euler Orientation
S_phi0_ic_rad = 0;
S_theta0_ic_rad = pi/10;
S_psi0_ic_rad = 0;

% Initial Body Rotation Rates
S_pb0_ic_rps = 0;
S_qb0_ic_rps = 0;
S_rb0_ic_rps = 0;

% Initial Mass Properties
S_mass0_ic_lbs = 300000;
S_Ixx_ic_slf2 = 10^6;
S_Iyy_ic_slf2 = 10^7;
S_Izz_ic_slf2 = 10^7;
S_Ixy_ic_slf2 = 0;
S_Iyz_ic_slf2 = 0;
S_Izx_ic_slf2 = 0;

%%Gains
%CL03_InnerLoopRegulator
cl03_roll_kp = 2.5;
cl03_pitch_kp = 4;
cl03_pitch_ki = 6.25;
cl03_yaw_kp = 2;
cl03_as_kp = 0.5;
cl03_climb_kp = 1.6;
cl03_climb_ki = 1;


%% Control Law Subsystem Parameters
% This section lists parameters used by each control law subsystem.
% Table Lookups

%% Enumerated Data Types

%% Checks


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
           {{'ElementName','roll_state_obm_dps2','DataType','double',  'Unit','dps2', 'Description','roll acceleration calculated in degrees'};
            {'ElementName','pitch_state_obm_dps2','DataType','double',  'Unit','dps2', 'Description','pitch acceleration calculated in degrees'};
            {'ElementName','yaw_state_obm_dps2','DataType','double',  'Unit','dps2', 'Description','yaw acceleration calculated in degrees'};
            {'ElementName','as_state_obm_fps2','DataType','double',  'Unit','fps2', 'Description','axial acceleration calculated in feet'};
            {'ElementName','climb_state_obm_fps2','DataType','double',  'Unit','fps2', 'Description','climb acceleration calculated in feet'};
            {'ElementName','Bmat_obm','DataType','double',  'Unit','nd',    'Description','Rotation Matrix NED to Body','Dimensions',[4,5]}    
           });

%%CL05_EffectorBlender
bus_helper(struct('BusName','B_CL05_EffBlend','HeaderFile','','Desc','CL05 Effector Blender','DataScope','Exported','Alignment','-1'),...
           {{'ElementName','symelv_cmd_deg','DataType','double',  'Unit','deg', 'Description','left elevon deflection in degrees'};
            {'ElementName','difelv_cmd_deg','DataType','double',  'Unit','deg', 'Description','right elevon deflection in degrees'};
            {'ElementName','drud_cmd_deg','DataType','double',  'Unit','deg', 'Description','rudder deflection in degrees'};
            {'ElementName','fprop_cmd_lbf','DataType','double',  'Unit','deg', 'Description','prop thrust in lbf'};
           });

