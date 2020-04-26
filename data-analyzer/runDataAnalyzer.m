% RUNDATAANALYZER starts the data analysis demo.
%
%                        REQUIRED VARIABLES:
%
%                        - Config: [struct] with fields:
%
%                                  - Simulator: [struct]; (created here)
%                                  - Model: [struct];
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------
clear variables
close('all','hidden')
clc

fprintf('\n#########################\n');
fprintf('\nData Analyzer \n');
fprintf('\n#########################\n\n');

disp('[runDataAnalyzer]: loading simulation setup...')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% USER DEFINED SIMULATION SETUP %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: create a static GUI with multiple selections instead of this manual
%       selection

% decide either to load the default model or to use the GUI to select it
Config.Simulator.useDefaultModel        = false; 

% activate/deactivate the iDyntree wrappers debug mode
Config.Simulator.wrappersDebugMode      = false;

% name of the folder that contains the default model
Config.Simulator.defaultModelFolderName = 'icubGazeboSim';

% create a video of the simulation
Config.Simulator.createVideo            = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('[runDataAnalyzer]: ready to start.')

% create a unique tag to identify the current simulation data, pictures and 
% video. The tag is the current hour and minute
%
% TODO: maybe find a better tag
c = clock;
Config.Simulator.savedDataTag = [num2str(c(4)),'_', num2str(c(5))];

% configure local paths
% 
% TODO: find a cleaner way to deal with local paths
addpath('../config/')
Config.Simulator.LocalPaths = configLocalPaths(); 
rmpath('../config/')

% add path to the "external" sources
addpath(genpath([Config.Simulator.LocalPaths.pathToExternal,'/FEX-function_handle']))

% create a list of all the folders containing the available models
Config.Simulator.modelFoldersList = mbs.getFoldersList('app');

if isempty(Config.Simulator.modelFoldersList)
    
    error('[runDataAnalyzer]: no model folders found.');
else
    % open the GUI for selecting the model or select the default model
    Config.Simulator.modelFolderName = mbs.openModelMenu(Config.Simulator);
end

if ~isempty(Config.Simulator.modelFolderName)

    disp(['[runDataAnalyzer]: loading the model: ', Config.Simulator.modelFolderName])
    
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
    gravCompHandle = function_handle('./src/dataAnalyzer.m');
    gravCompHandle(); 
    
    % remove simulation and models paths
    rmpath('./src');
    rmpath(genpath([Config.Simulator.LocalPaths.pathToModels,'/models/', Config.Simulator.modelFolderName]));
    
    % delete the temporary model and folder
    delete([Config.Model.modelPath, Config.Model.modelName]);

    if exist('TEMP','dir')
        rmdir('TEMP');
    end
end

% remove local paths
rmpath(genpath([Config.Simulator.LocalPaths.pathToExternal,'/FEX-function_handle']))

disp('[runDataAnalyzer]: simulation ended.') 
