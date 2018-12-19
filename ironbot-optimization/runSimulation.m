% RUNSIMULATION starts all the simulations related to the ironBot
%               optimization.
%
%                    REQUIRED VARIABLES:
%
%                    - Config: [struct] with fields:
%
%                              - Simulator: [struct]; (created here)
%                              - Model: [struct];
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------
clear variables
close('all','hidden')
clc

fprintf('\n###############################\n');
fprintf('\nironBot optimization simulation\n');
fprintf('\n###############################\n\n');

disp('[runSimulation]: loading simulation setup...')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% USER DEFINED SIMULATION SETUP %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: create a static GUI with multiple selections instead of this manual
%       selection

% decide either to run the default simulation or to use the GUI to select it
Config.Simulator.runDefaultSimulation   = false;
 
% show a simulation of the system and data plotting (only if available)
Config.Simulator.showVisualizer         = true;
Config.Simulator.showSimulationResults  = true;

% save data and/or pictures of the simulation (only if available)
Config.Simulator.saveSimulationResults  = false;
Config.Simulator.savePictures           = false;

% activate/deactivate the iDyntree wrappers debug mode
Config.Simulator.wrappersDebugMode      = false;

% name of the folder that contains the default model
Config.Simulator.defaultModelFolderName = 'ironBot';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('[runSimulation]: ready to start.')

% create a unique tag to identify the current simulation data, pictures and 
% video. The tag is the current hour and minute
%
% TODO: maybe find a better tag
c = clock;
Config.Simulator.savedDataTag = [num2str(c(4)),'_', num2str(c(5))];

% configure local paths
% 
% TODO: find a cleaner way to deal with local paths
addpath('../')
Config.Simulator.LocalPaths = configLocalPaths(); 
rmpath('../')

% add path to the "core" functions
addpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/core-functions']))
addpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/utility-functions']))
addpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/wrappers']))

% add path to the "external" sources
addpath(genpath([Config.Simulator.LocalPaths.pathToExternal,'/FEX-function_handle']))
addpath(genpath([Config.Simulator.LocalPaths.pathToExternal,'/FEX-minimize']))

% add path to common functions
addpath(genpath('./src/common-functions'));

% only model available: ironBot
Config.Simulator.modelFolderName = Config.Simulator.defaultModelFolderName;

if ~isempty(Config.Simulator.modelFolderName)

    disp(['[runSimulation]: loading the model: ', Config.Simulator.modelFolderName])
    
     % add the path to the urdf model and meshes, assuming your model is among
    % the ones available in the folder pointed by "Config.Simulator.LocalPaths.pathToModels"
    addpath(genpath([Config.Simulator.LocalPaths.pathToModels,'/models/', Config.Simulator.modelFolderName]));
    
    % run the model initialization script
    initModelHandle = function_handle(['app/',Config.Simulator.modelFolderName,'/init_', Config.Simulator.modelFolderName, '.m']);
    initModelHandle(); 
    
    if Config.Model.deactivateVisualizer
 
        % in case the visualizer is not available for the loaded model,
        % overwrite the 'showSimulation' variable option
        Config.Simulator.showVisualizer = false;
    end
    
    % open the menu for selecting the simulation
    [Config.Simulator.demoFolderName, Config.Simulator.demoScriptName] = openSimulationMenu(Config.Model, Config.Simulator);
    
    if ~isempty(Config.Simulator.demoScriptName)
    
        disp(['[runSimulation]: running ', Config.Simulator.demoScriptName, ' demo.'])
        
        % the demo script may not have an associated folder (not recommended)
        if ~isempty(Config.Simulator.demoFolderName)  
            
            % add the path to the simulations folder
            addpath(['./src/', Config.Simulator.demoFolderName])
        end
        
        % run the simulation
        simulationHandle = function_handle(['./src/', Config.Simulator.demoFolderName, '/', Config.Simulator.demoScriptName]);
        simulationHandle();
        
        % remove model path
        rmpath(genpath([Config.Simulator.LocalPaths.pathToModels,'/models/', Config.Simulator.modelFolderName]));
        
        if ~isempty(Config.Simulator.demoFolderName)  
            
            % remove the path to the simulations folder
            rmpath(['./src/', Config.Simulator.demoFolderName])
        end       
    end
    
    % delete the temporary model and folder
    delete([Config.Model.modelPath, Config.Model.modelName]);

    if exist('TEMP','dir')
        rmdir('TEMP');
    end
end

% remove local paths
rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/core-functions']))
rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/utility-functions']))
rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/wrappers']))
rmpath(genpath([Config.Simulator.LocalPaths.pathToExternal,'/FEX-function_handle']))
rmpath(genpath([Config.Simulator.LocalPaths.pathToExternal,'/FEX-minimize']))
rmpath(genpath('./src/common-functions'));

disp('[runSimulation]: simulation ended.') 