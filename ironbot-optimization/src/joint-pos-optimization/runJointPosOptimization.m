% RUNJOINTPOSOPTIMIZATION runs the joints position optimization simulation.
%
%                         REQUIRED VARIABLES:
%
%                         - Config: [struct] with fields:
%
%                                   - initJointPosOpt: [struct];
%                                   - optimization: [struct];
%                                   - TurbinesData: [struct];
%                                   - iDyntreeVisualizer: [struct];
%                                   - Simulator: [struct];
%                                   - Model: [struct];
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Dec 2018
    
%% ------------Initialization----------------

% run the script containing the initial conditions for the joint pos optimization
run(strcat(['./app/',Config.Simulator.modelFolderName,'/initJointPosOptimization.m']));

% create a modified urdf model that contains only the selected turbines
newModelName = generateUrdfModelForTesting(Config.TurbinesData,Config.Model);

% load the reduced model
KinDynModel  = idyn_loadReducedModel(Config.Model.jointList,Config.Model.baseLinkName,Config.Model.modelPath, ...
                                     newModelName,Config.Simulator.wrappersDebugMode); 
                   
% compute the world-to-base transform assuming one of the robot link is
% fixed on the ground, i.e.  it can be considered the inertial frame

% at the moment, it is assumed that only the two feet are fixed. Therefore
% the fixed link can be any of the two feet. 
%
% TODO: generalize to any link
%
if ~strcmp(Config.initJointPosOpt.fixedLinkName,'l_sole') && ~strcmp(Config.initJointPosOpt.fixedLinkName,'r_sole')
    
    error('[runJointPosOptimization]: at the moment, only "l_sole" and "r_sole" can be used as fixed links.')
end

base_H_fixedLink = idyn_getWorldTransform(KinDynModel,Config.initJointPosOpt.fixedLinkName);
w_H_b            = eye(4)/(base_H_fixedLink);

% correct the gravity acceleration according to the orientation of the
% fixedLink (which is assumed to be the inertial frame)
initWorldFrame_R_base      = eye(3);
initWorldFrame_R_fixedLink = initWorldFrame_R_base*base_H_fixedLink(1:3,1:3);
fixedLinkFrame_gravAcc     = initWorldFrame_R_fixedLink*Config.initJointPosOpt.gravityAcc;

% set the initial robot state 
idyn_setRobotState(KinDynModel,w_H_b,Config.initJointPosOpt.jointPos_init,zeros(6,1),Config.initJointPosOpt.jointVel_init,fixedLinkFrame_gravAcc);

% get the initial pose of the left and right foot
%
% TODO: generalize to any link
%
w_H_lFootInit = idyn_getWorldTransform(KinDynModel,'l_sole');
w_H_rFootInit = idyn_getWorldTransform(KinDynModel,'r_sole');

% update lower and upper bounds
lowerBound      = Config.optimization.lowerBound;
upperBound      = Config.optimization.upperBound; 

% generates the initial optimization vector uInit and the nonlinear constraints
uInit           = computeInitialConditions(w_H_b,Config.initJointPosOpt.jointPos_init,Config.initJointPosOpt.jetIntensities_init);

% adjust the upper/lower bounds for the base pose
lowerBound(1:6) = lowerBound(1:6) + uInit(1:6);
upperBound(1:6) = upperBound(1:6) + uInit(1:6);

% nonlinear constraints function
nonLinearConstraints = @(u) computeNonLinearConstraints(u,KinDynModel,fixedLinkFrame_gravAcc,...
                                                        Config.TurbinesData,w_H_lFootInit,w_H_rFootInit);

% compute the input variables to the optimization problem
costFunction = @(u) transpose(computeMomentumDerivative(u,KinDynModel,fixedLinkFrame_gravAcc,Config.TurbinesData))*...
                             (computeMomentumDerivative(u,KinDynModel,fixedLinkFrame_gravAcc,Config.TurbinesData))+...
                    transpose(u)*Config.optimization.WeightsMatrix*u;
                                                    
% nonlinear optimization to find the optimal posture. The problem to be
% solved is as follows:
%
%    min_u 1/2*(u^T*K*u)
%
%       s.t 
%           lb < u < ub
%           g(u) = 0

% set uptions of the nonlinear optimization
options = setoptimoptions('AlwaysHonorConstraints','all','MaxFunEvals',70000,'MaxIter',70000);
    
disp('[runJointPosOptimization]: running optimization...')
    
% nonlinear optimization
% [uStar, fval, exitflag, output] = minimize(costFunction,uInit,[],[],[],[],[],[],[],options);
% [uStar, fval, exitflag, output] = minimize(costFunction,uInit,[],[],[],[],lowerBound,upperBound,[],options);
[uStar, fval, exitflag, output] = minimize(costFunction,uInit,[],[],[],[],lowerBound,upperBound,nonLinearConstraints,options);

% delete the urdf model that has been created for the test
delete([Config.Model.modelPath, newModelName])
    
disp(['[runJointPosOptimization]: removing ', newModelName])

% visualize the joint position
if Config.Simulator.showVisualizer
    
    % convert u to the model state (required for the visualizer)
    ndof  = idyn_getNrOfDegreesOfFreedom(KinDynModel);
    njets = Config.TurbinesData.njets;
    
    [basePos, baseRot, jointPos, ~] = vectorDemux(uStar, [3;3;ndof;njets]);
    
    w_R_b = rotationFromRollPitchYaw(baseRot);
    w_H_b = [w_R_b, basePos;
              0   0   0  1];
          
    % run the visualizer
    runVisualizer(jointPos,w_H_b(:),Config.iDyntreeVisualizer.time,Config.iDyntreeVisualizer.createVideo,KinDynModel,Config.iDyntreeVisualizer,Config.Simulator);       
end

disp('[runJointPosOptimization]: optimization finished.')