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
Config.Model.jointList = {'jRightC7Shoulder_rotx', ...
                          'jRightShoulder_rotx', 'jRightShoulder_roty', 'jRightShoulder_rotz',...
                          'jRightElbow_roty', 'jRightElbow_rotz', ...
                          'jRightWrist_rotx', 'jRightWrist_rotz', ...
                          'jRightPalm_roty', ...
                          'jRightPinky1_rotz','jRightRing1_rotz','jRightMiddle1_rotz','jRightIndex1_rotz', ...
                          'jRightPinky1_rotx', 'jRightMiddle1_rotx', 'jRightRing1_rotx', 'jRightIndex1_rotx', ...
                          'jRightIndex2_rotx', 'jRightIndex3_rotx', ...
                          'jRightRing2_rotx', 'jRightRing3_rotx', ...
                          'jRightThumb1_rotz', 'jRightThumb1_roty', 'jRightThumb2_rotx', 'jRightThumb3_rotx', ...
                          'jRightMiddle2_rotx', 'jRightMiddle3_rotx', ...
                          'jRightPinky2_rotx' , 'jRightPinky3_rotx', ...
                          'jL5S1_rotx', 'jL5S1_roty', ...
                          'jL4L3_rotx', 'jL4L3_roty', ...
                          'jL1T12_rotx','jL1T12_roty', ...
                          'jT9T8_rotx', 'jT9T8_roty', 'jT9T8_rotz'}; % 38DoF
        
% select the link that will be used as base link
Config.Model.baseLinkName = 'Pelvis';

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
          