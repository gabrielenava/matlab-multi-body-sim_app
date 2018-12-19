% INITOPTIMIZEJETSPOSE initializes the jets pose optimization simulation.
%
%                      REQUIRED VARIABLES:
%
%                      - Config: [struct] with fields:
%
%                                - initJetsPoseOpt: [struct]; (created here)
%                                - iDyntreeVisualizer: [struct]; (created here)
%                                - Simulator; [struct].
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Jets pose optimization demo setup %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the initial robot position and velocity [deg] and gravity vector
torso_Position     = [0  0  0];                 
left_arm_Position  = [10 45 0  15 0];           
right_arm_Position = [10 45 0  15 0];                
left_leg_Position  = [0  0  0  0  0  0];
right_leg_Position = [0  0  0  0  0  0]; 

Config.initJetsPoseOpt.jointPos_init = [torso_Position';left_arm_Position';right_arm_Position';left_leg_Position';right_leg_Position']*pi/180;
Config.initJetsPoseOpt.jointVel_init = zeros(length(Config.initJetsPoseOpt.jointPos_init),1);
Config.initJetsPoseOpt.gravityAcc    = [0;0;-9.81];

% number of the tests to be performed. It can be a also a vector
Config.initJetsPoseOpt.testNumbersVector = 1:16;

% optimization: perform random joints movements, with random thrust
% forces,for the time specified by tMax
Config.initJetsPoseOpt.tMax           = 60; % [s]
Config.initJetsPoseOpt.jointPosLimits = 15; % [deg]
Config.initJetsPoseOpt.minThrust      = 10; % [N]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Visualization and data plotting setup %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% visualization settings may be complicated. For this reason, each model
% folder which uses complicated visualization settings has a file called
% 'initVisualization.m' which contains the visualization settings for each
% simulations which requires plotting
initVisualization;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% iDyntree visualizer setup %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the view options for the visualizer (model simulator with iDyntree)
Config.iDyntreeVisualizer.debug                    = false;
Config.iDyntreeVisualizer.cameraPos                = [1,0,0.5];    
Config.iDyntreeVisualizer.cameraTarget             = [0.4,0,0.5];
Config.iDyntreeVisualizer.lightDir                 = [-0.5 0 -0.5]/sqrt(2);
Config.iDyntreeVisualizer.disableViewInertialFrame = true;
Config.iDyntreeVisualizer.w_R_b_fixed              = [-1  0  0;
                                                       0 -1  0;
                                                       0  0  1];
Config.iDyntreeVisualizer.w_H_b_fixed              = [Config.iDyntreeVisualizer.w_R_b_fixed , [0;0;0.7];
                                                              0        0        0                 1   ];