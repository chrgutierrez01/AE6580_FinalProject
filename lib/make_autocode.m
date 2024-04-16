%% Autocode Build Function
%
%
%  run_autocode('clean')   will delete all generated files and rebuild
%  run_autocode()          will only regerate changed models
%
%  run_autocode([],'shared_dll') 
%       will change the CFG to create the
%       shared_dll for realflight. Recommended to then restart matlab if you
%       want to build the regular version of the autocode afterward.
%
%
%
function make_autocode(mode,target,output_path,model_name)

    % Options
    if nargin<4 || isempty(model_name)
        model_name = 'top_level_claw';    
    end
    
    ForceTopModelBuild = true;
    OkayToPushNags = true;
    OpenBuildStatusAutomatically=true;
    generateCodeOnly=true;
    configuration_name = 'Configuration';
    
    SMLK_CODE_DIR = Simulink.fileGenControl('get','CodeGenFolder');
    
    global CLAW_TOP_LEVEL_DIR;
    
    % ---- Check for TOP_LEVEL_DIR and that we are in it.
    if ~exist('CLAW_TOP_LEVEL_DIR','var') || isempty(CLAW_TOP_LEVEL_DIR)
        error('Ensure the model is opened before running make_autocode')
    end
    if ~strcmp(pwd,CLAW_TOP_LEVEL_DIR)
        error('Ensure the current working directory is "%s" before running make_autocode',CLAW_TOP_LEVEL_DIR)
    end

    % ----
    if nargin<1 || isempty(mode)
        mode='normal';
    end
    if nargin<2 || isempty(target)
        target = 'autocode';
    end
    tgt_options = {'autocode','shared_dll'};
    if all(cellfun(@isempty,strfind(tgt_options,target)))
        error(sprintf('Invalid target specific. Valid options are: %s',sprintf('%s,',tgt_options{:})))
    end
    if nargin<3 || isempty(output_path)
        output_path='autocode';
    end
    fprintf('\n*** Autocode output path: %s *** \n\n',output_path)

    make_clean=false;
    switch mode
        case 'normal'
            make_clean = false;
        case 'clean'
            make_clean=true;
        otherwise
            error('Unknonwn mode flag.')
    end
        
    
    %% Load and update the model  
    load_system(model_name)
    set_param(model_name, 'SimulationCommand', 'update')


    
    %% do we need to build the shared DLL?
    if strcmp(target,'shared_dll')
        disp(sprintf('\n\n Building shared DLL\n\n'))
        % https://www.mathworks.com/help/rtw/ug/configure-model-from-command-line.html
%         evalin('base', sprintf("switchTarget(%s,'ert_shrlib.tlc',[])",configuration_name))
        evalin('base',sprintf("%s.set_param('SystemTargetFile', 'ert_shrlib.tlc')",configuration_name))
        make_clean=true;
        generateCodeOnly=false;
    end

    %% Clean
    if make_clean
        clear_directory(Simulink.fileGenControl('get','CacheFolder'));
        clear_directory(Simulink.fileGenControl('get','CodeGenFolder'));
    end
    
    %% Build
    % 'Mode','ExportFunctionCalls'
    v=ver('MATLAB');
    if v.Release == "(R2017a)"
        rtwbuild(model_name,'ForceTopModelBuild',ForceTopModelBuild,...
                            'generateCodeOnly',generateCodeOnly,...
                            'OkayToPushNags',OkayToPushNags);
    else
        rtwbuild(model_name,'ForceTopModelBuild',ForceTopModelBuild,...
                            'generateCodeOnly',generateCodeOnly,...
                            'OkayToPushNags',OkayToPushNags,...
                            'OpenBuildStatusAutomatically',OpenBuildStatusAutomatically);
    end


    %% Consolidate Files
    if strcmp(target,'autocode')
        % skip this if we are making the shared dll
        f_cpp = find_files(SMLK_CODE_DIR, '*.cpp');
        f_c = find_files(SMLK_CODE_DIR, '*.c');
        f_h = find_files(SMLK_CODE_DIR, '*.h');
        files = cat(2,f_cpp,f_h,f_c);

        ignore_dir={'\sil\','\coderassumptions\'}; % ignore anything in the 'sil' or 'coderassumptions' directory
        [~,~]=mkdir(output_path); clear_directory(fullfile(output_path));
        for ix=1:numel(files)
            fname=fullfile(files{ix});
            if all(cellfun(@(x) isempty(strfind(fname,x)),ignore_dir)) % do not include SIL files
                copyfile(fname,output_path)
            end
        end
    end
    
    fprintf('\n*** Autocode output path: %s *** \n\n',output_path)
    
    % Check if a report was created
    codegen_report_src_dir = fullfile(SMLK_CODE_DIR,sprintf('%s_ert_rtw/html',model_name));
    codegen_report_dest_dir = fullfile(output_path,'codegen_html');
    if exist(codegen_report_src_dir,'dir')
        % copy report html directory to doc
        [~,~] = mkdir(codegen_report_dest_dir); % don't care if it exists or not already
        clear_directory(codegen_report_dest_dir);
        copyfile(fullfile(codegen_report_src_dir,'*'),codegen_report_dest_dir)
    end
        
    % Check if we are in a git repo
    [status,output] = system('git rev-parse --is-inside-work-tree');
    if status==0 && strfind(output,'true')
        in_git_repo = true;
    else
        in_git_repo = false;
    end
    
    % Revert irrelevant changes as requested
    if in_git_repo && exist('check_autocode_timestamp_only.m','file')
        choice = input('Do you want to revert irrelevant changes (eg. autocode timestamps in source) [Y]/n: ','s');
        if isempty(choice) || (length(choice)==1 && lower(choice)=='y')
            check_autocode_timestamp_only(output_path,true);
            if exist(fullfile(output_path,'codegen_html'),'dir')
                check_autocode_timestamp_only(fullfile(output_path,'codegen_html'),true);
            end
        else
            check_autocode_timestamp_only(output_path,false);
        end
    end
        

end

%%
function files = find_files(Folder, Pattern)
% Get matching files in current folder:

%             d = dir(sprintf('%s\\%s',item{1},ext));
%             d = d(~ismember({d.name},{'.','..'}));
%             names = {d.name};


    List  = dir(fullfile(Folder, Pattern));
    files = cellfun(@(s) fullfile(Folder, s), ...
        {List(~[List.isdir]).name}, 'UniformOutput', 0);
    % Get folders in current folder:
    List    = dir(Folder);
    Folders = {List([List.isdir]).name};
    Folders(strcmp(Folders, '.') | strcmp(Folders, '..')) = [];
    for k = 1:numel(Folders)  % Loop over all folders:
      % Call this function recursively for subfolders:
      files = cat(2, files, ...
                  find_files(fullfile(Folder, Folders{k}), Pattern));
    end

end

%% 
function clear_directory(path_to_dir)
    if exist(path_to_dir,'dir')
        % get contents
        d = dir(path_to_dir);
        d = d(~ismember({d.name},{'.','..'}));
        names = {d.name};
        %remove files
        cellfun(@(x) delete(fullfile(path_to_dir,x)), names(~[d.isdir]));
        %remove dirs
        cellfun(@(x) rmdir(fullfile(path_to_dir,x),'s'), names([d.isdir]));
        [~,~,~]=mkdir(path_to_dir); % suppress warnings
    else
        warning(sprintf("Directory '%s' not found.",path_to_dir));
    end
end
