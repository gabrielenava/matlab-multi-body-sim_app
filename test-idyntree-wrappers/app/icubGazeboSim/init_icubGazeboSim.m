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
Config.Model.jointList = {'torso_pitch','torso_roll','torso_yaw', ...
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

% generate the temporary model
if ~exist('TEMP','dir')
    mkdir('TEMP');
end

pathToOriginalModel = [Config.Simulator.LocalPaths.pathToModels,'/models/', Config.Simulator.modelFolderName,'/'];
originalModelName   = 'model.urdf';

% tag to substitute with the local path, and new path
originalPathString  = 'ABSOLUTE_PATH_TO_MESHES';
mbs.editUrdfModel(pathToOriginalModel, originalModelName, Config.Model.modelPath, ...
                  Config.Model.modelName, originalPathString, [pathToOriginalModel,'meshes']);
          
% specify if the iDyntree simulator is available for this model. It may not
% be available e.g. in case meshes are required to visualize the model links, 
% and the ones available are not of the proper format (.dae)
Config.Model.deactivateVisualizer = false;
