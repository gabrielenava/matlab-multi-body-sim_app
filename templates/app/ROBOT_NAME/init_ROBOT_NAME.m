% INIT_ROBOT_NAME initializes the reduced model. NOTE: the reduced model is NOT 
%                 jet loaded. This file just contains the model configuration.
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

% REQUIRED: specify the list of joints that are going to be considered in the reduced model
Config.Model.jointList = {};
        
% REQUIRED: select the link that will be used as base link
Config.Model.baseLinkName = '';

% REQUIRED: model name and path to the urdf model
Config.Model.modelName = 'myModel.urdf';
Config.Model.modelPath = './';