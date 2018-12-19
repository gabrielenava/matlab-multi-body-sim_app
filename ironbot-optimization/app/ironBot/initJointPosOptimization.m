% INITJOINTPOSOPTIMIZATION initializes the joint position optimization simulation.
%
%                      REQUIRED VARIABLES:
%
%                      - Config: [struct] with fields:
%
%                                - initJointPosOpt: [struct] (created here);
%                                - optimization: [struct] (created here);
%                                - TurbinesData: [struct] (created here);
%                                - iDyntreeVisualizer: [struct] (created here);
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Dec 2018
    
%% ------------Initialization----------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% joint pos optimization demo setup %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set the initial robot position and velocity [deg] and gravity vector
torso_Position     = [0  0  0];                 
left_arm_Position  = [-40 45 0  15 0];           
right_arm_Position = [-40 45 0  15 0];                
left_leg_Position  = [0  0  0  0  0  0];
right_leg_Position = [0  0  0  0  0  0]; 

Config.initJointPosOpt.jointPos_init = [torso_Position';left_arm_Position';right_arm_Position';left_leg_Position';right_leg_Position']*pi/180;
Config.initJointPosOpt.jointVel_init = zeros(length(Config.initJointPosOpt.jointPos_init),1);
Config.initJointPosOpt.gravityAcc    = [0;0;-9.81];

% initial jets intensities
Config.initJointPosOpt.jetIntensities_init = [170; 170; 0; 0]; %[N]

% specify the name of the link which is considered fixed on ground. At the
% moment, the world link can be only "l_sole" or "r_sole"
%
% TODO: extend to any fixed link
%
Config.initJointPosOpt.fixedLinkName = 'l_sole';

% include fixed link constraints in the optimization procedure
Config.initJointPosOpt.useFixedLinkConstraints = true;

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

% define the length of the optimization vector
optimizationVectorLength = 6+length(Config.initJointPosOpt.jointPos_init)+Config.TurbinesData.njets;

% weigths matrices
WeightsBasePos  = 1.*eye(3);
WeightsBaseRot  = 1.*eye(3);
WeightsJointPos = 0.1.*eye(length(Config.initJointPosOpt.jointPos_init));
WeightsTurbines = 1e-2.*eye(Config.TurbinesData.njets);

% adjust the weights on the arms joints and turbines
for k = 4:13

    WeightsJointPos(k,k) = 0.1;
end

WeightsTurbines(3,3) = 1;
WeightsTurbines(4,4) = 1;

Config.optimization.WeightsMatrix = blkdiag(WeightsBasePos,WeightsBaseRot,WeightsJointPos,WeightsTurbines);

% weights on momentum
Config.optimization.WeightsMatrixMomentum = blkdiag(diag([10 10 0]),100*eye(3));

% lower and upper bounds

% limits for the joints positions
jointPosDelta      = 60*pi/180; %[rad] 
upperBoundJointPos = Config.initJointPosOpt.jointPos_init + jointPosDelta;
lowerBoundJointPos = Config.initJointPosOpt.jointPos_init - jointPosDelta;

% not the final base pose limits. They are updated inside "runJointPosOptimization"
basePosDelta       =  0.25;      %[m]
baseRotDelta       =  40*pi/180; %[rad]
upperBoundBasePos  =  basePosDelta.*ones(3,1); %[m]
upperBoundBaseRot  =  baseRotDelta.*ones(3,1); %[rad]
lowerBoundBasePos  = -basePosDelta.*ones(3,1); %[m]
lowerBoundBaseRot  = -baseRotDelta.*ones(3,1); %[rad]

% turbines bounds
upperBoundTurbines = transpose(Config.TurbinesData.turbineLimits);
lowerBoundTurbines = zeros(Config.TurbinesData.njets,1);

Config.optimization.upperBound = [upperBoundBasePos;upperBoundBaseRot;upperBoundJointPos;upperBoundTurbines];
Config.optimization.lowerBound = [lowerBoundBasePos;lowerBoundBaseRot;lowerBoundJointPos;lowerBoundTurbines];

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
Config.iDyntreeVisualizer.time                     = 10; %[s]