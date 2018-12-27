% INITWRAPPERSTEST initializes the iDyntree-wrappers test. NOTE that 
%                  the soundness of the wrappers inputs/outputs is
%                  instead tested by setting the variable "wrappersDebugMode"
%                  to TRUE.
%
%                  REQUIRED VARIABLES:
%
%                  - Config: [struct] with fields:
%
%                            - initWrappersTest: [struct]; (created here)
%                            - iDyntreeVisualizer: [struct]; (created here)
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% iDyntree wrappers test demo setup %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the initial robot position and velocity [deg]
torso_Position     = [0  0  0];                 
left_arm_Position  = [10 45 0  15 0];           
right_arm_Position = [10 45 0  15 0];         
right_leg_Position = [0  0  0  0  0  0];        
left_leg_Position  = [0  0  0  0  0  0];

Config.initWrappersTest.jointPos_init = [torso_Position';left_arm_Position';right_arm_Position';left_leg_Position';right_leg_Position']*pi/180;
Config.initWrappersTest.jointVel_init = zeros(length(Config.initWrappersTest.jointPos_init),1);

% other configuration parameters
Config.initWrappersTest.gravityAcc   = [0;0;-9.81];
Config.initWrappersTest.frameVelRepr = 'mixed';
Config.initWrappersTest.frameName    = 'l_sole';
Config.initWrappersTest.frame2Name   = 'r_sole';
Config.initWrappersTest.frameID      = 1;
Config.initWrappersTest.frame2ID     = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% iDyntree visualizer setup %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the view options for the iDyntree visualizer
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