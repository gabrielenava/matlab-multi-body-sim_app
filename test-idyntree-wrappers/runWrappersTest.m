% RUNWRAPPERSTEST tests the functionality of the idyntree-high-level-wrappers.
%                 NOTE that the soundness of the wrappers inputs/outputs is
%                 instead tested by setting the variable "wrappersDebugMode"
%                 to TRUE.
%
%                 REQUIRED VARIABLES:
%
%                 - Config: [struct] with fields:
%
%                           - Simulator: [struct]; (created here)
%                           - Model: [struct];
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------
clear variables
close('all','hidden')
clc

fprintf('\n#################################\n');
fprintf('\niDyntree high-level-wrappers test\n');
fprintf('\n#################################\n\n');

disp('[runWrappersTest]: loading simulation setup...')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% USER DEFINED SIMULATION SETUP %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: create a static GUI with multiple selections instead of this manual
%       selection

% decide either to load the default model or to use the GUI to select it
Config.Simulator.useDefaultModel        = false; 

% show a simulation of the system (only if available)
Config.Simulator.showVisualizer         = true;

% activate/deactivate the iDyntree wrappers debug mode
Config.Simulator.wrappersDebugMode      = true;

% name of the folder that contains the default model
Config.Simulator.defaultModelFolderName = 'icubGazeboSim';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('[runWrappersTest]: ready to start.')

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

% create a list of all the folders containing the available models
Config.Simulator.modelFoldersList = getFoldersList('app');

if isempty(Config.Simulator.modelFoldersList)
    
    error('[runWrappersTest]: no model folders found.');
else
    % open the GUI for selecting the model or select the default model
    Config.Simulator.modelFolderName = openModelMenu(Config.Simulator);
end

if ~isempty(Config.Simulator.modelFolderName)

    disp(['[runWrappersTest]: loading the model: ', Config.Simulator.modelFolderName])
    
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
    
    % add path to simulation-specific sources
    addpath('./src');
    
    % run the simulation
    wrapperHandle = function_handle('./src/wrappersTest.m');
    wrapperHandle(); 
    
    % remove simulation and models paths
    rmpath('./src');
    rmpath(genpath([Config.Simulator.LocalPaths.pathToModels,'/models/', Config.Simulator.modelFolderName]));
    
    % delete the temporary model and folder
    delete([Config.Model.modelPath, Config.Model.modelName]);

    if exist('TEMP','dir')
        rmdir('TEMP');
    end
end

% remove the remaining local paths
rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/core-functions']))
rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/utility-functions']))
rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/wrappers']))
rmpath(genpath([Config.Simulator.LocalPaths.pathToExternal,'/FEX-function_handle']))

disp('[runWrappersTest]: simulation ended.') 