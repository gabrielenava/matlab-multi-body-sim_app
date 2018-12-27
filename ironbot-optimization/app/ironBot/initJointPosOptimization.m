% INITJOINTPOSOPTIMIZATION initializes the joint position optimization simulation.
%
%                          REQUIRED VARIABLES:
%
%                          - Config: [struct] with fields:
%
%                                    - initJointPosOpt: [struct] (created here);
%                                    - optimization: [struct] (created here);
%                                    - TurbinesData: [struct] (created here);
%                                    - iDyntreeVisualizer: [struct] (created here);
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Dec 2018
    
%% ------------Initialization----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% joint pos optimization demo setup %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the initial robot position and velocity [deg] and gravity vector
torso_Position     = [ 5  0  0];                 
left_arm_Position  = [-20 30 50  15 15];           
right_arm_Position = [-20 30 50  15 15];                
left_leg_Position  = [ 0  0  0  0  0  0];
right_leg_Position = [ 0  0  0  0  0  0]; 

Config.initJointPosOpt.jointPos_init = [torso_Position';left_arm_Position';right_arm_Position';left_leg_Position';right_leg_Position']*pi/180;
Config.initJointPosOpt.jointVel_init = zeros(length(Config.initJointPosOpt.jointPos_init),1);
Config.initJointPosOpt.gravityAcc    = [0;0;-9.81];

% initial jets intensities
Config.initJointPosOpt.jetIntensities_init = [200; 200; 50; 50]; %[N]

% include fixed link constraints in the optimization procedure
Config.initJointPosOpt.useFixedLinkConstraints = true;

% initial base pose w.r.t. the world frame
Config.initJointPosOpt.w_R_b_init = [-1  0  0;
                                      0 -1  0;
                                      0  0  1];
Config.initJointPosOpt.w_H_b_init = [Config.initJointPosOpt.w_R_b_init , [0;0;0.7];
                                         0        0        0                 1   ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% turbines data structure setup %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate the TurbinesData structure
Config.TurbinesData.turbineList   = {'chest_l_jet_turbine','chest_r_jet_turbine','l_arm_jet_turbine_prime','r_arm_jet_turbine_prime'};
Config.TurbinesData.turbineAxis   = [-3; -3; 3; 3];
Config.TurbinesData.turbineLimits = [220, 220, 100, 100]; 
Config.TurbinesData.njets         = length(Config.TurbinesData.turbineList);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% nonlinear optimization setup %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% weigths matrices
WeightsBasePos  = 0.01.*eye(3);
WeightsBaseRot  = 0.01.*eye(3);
WeightsJointPos = 0.01.*eye(length(Config.initJointPosOpt.jointPos_init));
WeightsTurbines = 0.01.*eye(Config.TurbinesData.njets);

Config.Optimization.WeightsMatrix = blkdiag(WeightsBasePos,WeightsBaseRot,WeightsJointPos,WeightsTurbines);

% weights on momentum
Config.Optimization.WeightsMatrixMomentum = blkdiag(diag([10, 10, 10]), diag([10, 100, 10]));

% lower and upper bounds

% joints limits. The order is hard-coded.
%
% TODO: avoid hard-coding the order of the joints
jointPositionLimits = [-20,  70; -30,  30;  -50,  50; ... %torso
                       -90,  10;  0,   160; -35,  80;  15,  105; -60,  60; ... %larm
                       -90,  10;  0,   160; -35,  80;  15,  105; -60,  60; ... %rarm
                       -35,  80; -15,  90;  -70,  70; -100, 0;   -30,  30; -20,  20; ... %rleg  
                       -35,  80; -15,  90;  -70,  70; -100, 0;   -30,  30; -20,  20]; %lleg

upperBoundJointPos = jointPositionLimits(:,2)*pi/180;
lowerBoundJointPos = jointPositionLimits(:,1)*pi/180;

% limits for the base pose
basePosDelta       =  0.05;      %[m]
baseRotDelta       =  20*pi/180; %[rad]
upperBoundBasePos  =  Config.initJointPosOpt.w_H_b_init(1:3,4) + basePosDelta.*ones(3,1); %[m]
upperBoundBaseRot  =  rollPitchYawFromRotation(Config.initJointPosOpt.w_H_b_init(1:3,1:3)) + baseRotDelta.*ones(3,1); %[rad]
lowerBoundBasePos  =  Config.initJointPosOpt.w_H_b_init(1:3,4) - basePosDelta.*ones(3,1); %[m]
lowerBoundBaseRot  =  rollPitchYawFromRotation(Config.initJointPosOpt.w_H_b_init(1:3,1:3)) - baseRotDelta.*ones(3,1); %[rad]

% turbines bounds
upperBoundTurbines = transpose(Config.TurbinesData.turbineLimits);
lowerBoundTurbines = zeros(Config.TurbinesData.njets,1);

Config.Optimization.upperBound = [upperBoundBasePos;upperBoundBaseRot;upperBoundJointPos;upperBoundTurbines];
Config.Optimization.lowerBound = [lowerBoundBasePos;lowerBoundBaseRot;lowerBoundJointPos;lowerBoundTurbines];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% iDyntree visualizer setup %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the view options for the visualizer (model simulator with iDyntree)
Config.iDyntreeVisualizer.debug                    = false;
Config.iDyntreeVisualizer.cameraPos                = [1,0,0.5];    
Config.iDyntreeVisualizer.cameraTarget             = [0.4,0,0.5];
Config.iDyntreeVisualizer.lightDir                 = [-0.5 0 -0.5]/sqrt(2);
Config.iDyntreeVisualizer.disableViewInertialFrame = true;
Config.iDyntreeVisualizer.createVideo              = false;

% time for which the simulator is shown
Config.iDyntreeVisualizer.time                     = 15; %[s]