% INITDATAANALYSIS initializes the data analysis simulation.
%
%                         REQUIRED VARIABLES:
%
%                         - Config: [struct] with fields:
%
%                                   - initDataAnalysis: [struct]; (created here)
%                                   - integration: [struct]; (partially created here)
%                                   - iDyntreeVisualizer: [struct]; (created here)
%                                   - Simulator: [struct].
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Data analysis demo setup %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the initial robot position and velocity [deg] and gravity vector
Config.initDataAnalysis.gravityAcc = [0;0;-9.81];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% iDyntree visualizer setup %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the view options for the visualizer (model simulator with iDyntree)
Config.iDyntreeVisualizer.debug                    = false;
Config.iDyntreeVisualizer.cameraPos                = [1.5, 0, 0.0];    
Config.iDyntreeVisualizer.cameraTarget             = [0.5 0 0];
Config.iDyntreeVisualizer.lightDir                 = [-0.5 0 -0.5]/sqrt(2);
Config.iDyntreeVisualizer.disableViewInertialFrame = true;
