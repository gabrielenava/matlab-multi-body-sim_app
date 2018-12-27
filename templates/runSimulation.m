% RUNSIMULATION this script configures user-defined options for running a
%               specific simulation.
%
%               REQUIRED VARIABLES:
%
%               - Config: [struct] with fields:
%
%                         - Simulator: [struct]; (created here)
%                         - Model: [struct];
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------
clear variables
close('all','hidden')
clc

fprintf('\n###################\n');
fprintf('\nSimulation template \n');
fprintf('\n###################\n\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% USER DEFINED SIMULATION SETUP %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the user-defined options. The number and type of these options
% depends on the simulation. You may try to structure the options as the
% one below, but no specific rules are required.

% REQUIRED: activate/deactivate the iDyntree wrappers debug mode
Config.Simulator.wrappersDebugMode = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% REQUIRED: configure local paths.
addpath('../')
Config.Simulator.LocalPaths = configLocalPaths(); 
rmpath('../')

% REQUIRED: add path to the "core" functions
addpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/core-functions']))
addpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/utility-functions']))
addpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/wrappers']))

% OPTIONAL: add path to the "external" sources

% REQUIRED: create a list of all the folders containing the available models
%
% if ROBOT_NAME is the name you chose for your robot, it is required that a 
% folder called ROBOT_NAME is present in the "app" folder.
%
% Furthermore, the ROBOT_NAME folder must contain a Matlab script named
% init_ROBOT_NAME.m, that contains ONLY the basic information required to
% load the urdf model.
%
% Finally, the ROBOT_NAME folder must also contain the urdf model. It is
% also possible that the urdf model is in another folder (pointed by the
% "Config.Simulator.LocalPaths" variable) also called ROBOT_NAME
Config.Simulator.modelFoldersList = getFoldersList('app');

% REQUIRED: select your model folder name among the ones in the list
Config.Simulator.modelFolderName = Config.Simulator.modelFoldersList{1};

% REQUIRED: run the model initialization script
run(strcat(['app/',Config.Simulator.modelFolderName,'/init_', Config.Simulator.modelFolderName, '.m']));

% add path to simulation-specific sources
addpath('./src');
    
% run the simulation
run(strcat('./src/mySimulation.m')); 
    
% remove local paths
rmpath('./src');
rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/core-functions']))
rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/utility-functions']))
rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/wrappers']))

disp('[runSimulation]: simulation ended.') 