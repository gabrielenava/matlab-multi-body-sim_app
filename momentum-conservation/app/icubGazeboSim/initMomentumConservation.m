% INITMOMENTUMCONSERVATION initializes the momentum conservation simulation.
%
%                          REQUIRED VARIABLES:
%
%                          - Config: [struct] with fields:
%
%                                    - initMomCons: [struct]; (created here)
%                                    - integration: [struct]; (partially created here)
%                                    - iDyntreeVisualizer: [struct]; (created here)
%                                    - Simulator: [struct].
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Dec 2018
    
%% ------------Initialization----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Momentum conservation demo setup %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the initial robot position and velocity [deg] and gravity vector
torso_Position     = [0  0  0];                 
left_arm_Position  = [10 45 0  15 0];           
right_arm_Position = [10 45 0  15 0];                
left_leg_Position  = [0  0  0  0  0  0];
right_leg_Position = [0  0  0  0  0  0]; 

Config.initMomCons.jointPos_init = [torso_Position';left_arm_Position';right_arm_Position';left_leg_Position';right_leg_Position']*pi/180;
Config.initMomCons.jointVel_init = zeros(length(Config.initMomCons.jointPos_init),1);
Config.initMomCons.baseVel_init  = zeros(6,1);

% initial base pose
w_R_b_init                       = [-1  0  0;
                                     0 -1  0;
                                     0  0  1];
                                 
Config.initMomCons.w_H_b_init    = [w_R_b_init , [0;0;0.7];
                                    0  0  0          1   ];
                                
% zero gravity
Config.initMomCons.gravityAcc    = [0;0;0];

% references for the joint velocities
Config.initMomCons.Amplitude     = 10*pi/180; % [rad/s]
Config.initMomCons.Frequency     = 0.5;       % [Hz]

% project the joint velocities in the nullspace of the momentum equation
Config.initMomCons.USE_MOMENTUM_NULLSPACE = true;
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Numerical integration setup %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the integration time step, total time, and the integration options
Config.integration.tStart      = 0;
Config.integration.tEnd        = 10;
Config.integration.tStep       = 0.01; 
Config.integration.showStats   = 'off';
Config.integration.options     = odeset('RelTol',1e-3,'AbsTol',1e-3,'Stats',Config.integration.showStats);
Config.integration.showWaitbar = true;
   
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
Config.iDyntreeVisualizer.w_H_b_fixed              = Config.initMomCons.w_H_b_init;