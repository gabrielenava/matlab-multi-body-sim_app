% INIT_ROBOTNAME initializes the reduced model. NOTE: the reduced model is NOT 
%                jet loaded. This file just contains the model configuration.
%
%                REQUIRED VARIABLES:
%
%                - Config: [struct] with fields:
%
%                          - Simulator: [struct];
%                          - Model: [struct]; (created here)
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------

% specify the list of joints that are going to be considered in the reduced model
Config.Model.jointList = {'torso_pitch','torso_roll','torso_yaw',...
                          'l_shoulder_pitch','l_shoulder_roll','l_shoulder_yaw','l_elbow','l_wrist_prosup', ...
                          'r_shoulder_pitch','r_shoulder_roll','r_shoulder_yaw','r_elbow','r_wrist_prosup', ...
                          'l_hip_pitch','l_hip_roll','l_hip_yaw','l_knee','l_ankle_pitch','l_ankle_roll', ...
                          'r_hip_pitch','r_hip_roll','r_hip_yaw','r_knee','r_ankle_pitch','r_ankle_roll'};
        
% select the link that will be used as base link
Config.Model.baseLinkName = 'root_link';

% model name and path to the urdf file. At the moment, the iDyntree visualizer 
% requires to specify inside the urdf model the absolute path from the script
% running the visualizer to the meshes. This requires to hard-code local paths 
% inside the urdf model.
%
% WORKAROUND: a temporary model "modelTEMP.urdf" is created. It is a
% temporary copy of the original urdf model, with the path to the meshes 
% properly set. The model is deleted at the end of the simulation. 
%
% TODO: modify the iDyntree visualizer source code
Config.Model.modelName = 'modelTEMP.urdf';
Config.Model.modelPath = './TEMP/';

% generate the temporary model. ironBot uses part of the meshes of iCubGazeboV2_5
if ~exist('TEMP','dir')
    mkdir('TEMP');
end

pathToOriginalModel = [Config.Simulator.LocalPaths.pathToModels,'/models/', Config.Simulator.modelFolderName,'/'];
pathToV2_5Model     = [Config.Simulator.LocalPaths.pathToModels,'/models/iCubGazeboV2_5/'];
originalModelName   = 'model.urdf';

% tag to substitute with the local path, and new path
originalPathString_iCubV2_5 = 'ABSOLUTE_PATH_TO_MESHES';
originalPathString_ironBot  = 'ABSOLUTE_PATH_TO_TURBINES_MESHES';
editUrdfModel(pathToOriginalModel, originalModelName, Config.Model.modelPath, ...
              Config.Model.modelName, originalPathString_iCubV2_5, [pathToV2_5Model,'meshes']);
editUrdfModel(Config.Model.modelPath, Config.Model.modelName, Config.Model.modelPath, ...
              Config.Model.modelName, originalPathString_ironBot, [pathToOriginalModel,'meshes']);

% list of available simulations. Each name specified in the simulation list
% is the name of the script that runs the corresponding demo
Config.Model.simulationList = {'runJointPosOptimization','runJetsPoseOptimization'};

% for each element of the "simulationList" there should be a corresponding
% folder inside the "simulations" folder where all the functions and
% scripts relative to each demo are stored. If not, just put an empty string
Config.Model.demoFolderList = {'joint-pos-optimization','jets-pose-optimization'};

% default simulation and default demo folder
Config.Model.defaultSimulation = 'runJointPosOptimization';
Config.Model.defaultDemoFolder = 'joint-pos-optimization';

% specify if the iDyntree simulator is available for this model. It may not
% be available e.g. in case meshes are required to visualize the model links, 
% and the ones available are not of the proper format (.dae)
Config.Model.deactivateVisualizer = false;

% checks on the simulation list
if isempty(Config.Model.simulationList)
    
    % TODO: define a default "simulation" which just loads the selected
    %       model, and allows for running all the other simulations
    error('[init_ironBot]: simulationList cannot be empty.')
end

if length(Config.Model.simulationList) ~= length(Config.Model.demoFolderList)
    
    % if a simulation script does not have an associated folder, just put 
    % an empty string as corresponding element of the 'demoFolderList'
    error('[init_ironBot]: simulationList and demoFolderList are not consistent.')
end