% INIT_SIMULATION initializes the user-defined simulation.
%
%     REQUIRED VARIABLES:
%
%         - Config: [struct] with fields:
%
%             - Simulator: [struct];
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018; Modified Sept. 2020
    
%% ------------Initialization----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% iDyntree visualizer setup %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the view options for the iDynTree visualizer
Config.iDyntreeVisualizer.meshesPath         =  Config.Simulator.pathToModel;
Config.iDyntreeVisualizer.color              =  [0.9,0.9,0.9];
Config.iDyntreeVisualizer.material           = 'metal';
Config.iDyntreeVisualizer.transparency       =  1;
Config.iDyntreeVisualizer.debug              =  false; 
Config.iDyntreeVisualizer.view               =  [-92.9356   22.4635];
Config.iDyntreeVisualizer.groundOn           =  false; 
Config.iDyntreeVisualizer.groundColor        =  [0.5 0.5 0.5];
Config.iDyntreeVisualizer.groundTransparency =  0.5;
Config.iDyntreeVisualizer.groundFrame        = ' ';

% create video and frame rate for video recording (fps)
Config.Simulator.createVideo                 = false;
Config.iDyntreeVisualizer.frameRate          = 24;
