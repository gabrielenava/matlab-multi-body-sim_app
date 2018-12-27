% RUNJOINTPOSOPTIMIZATION runs the joints position optimization simulation.
%                         The objective is to find a joints configuration
%                         that can be used as reference for the ironBot
%                         controller's postural task. The optimal
%                         configuration is calculated by solving the
%                         following minimization problem:
%
%                         min_u 1/2*((u-u^d)^T*K_u*(u-u^d) + LDot(u)^T*K_L*LDot(u))
%
%                             s.t  
%                                  lb < u < ub
%                                  g(u) = 0
%                                  h(u) <= 0
%
%                         REQUIRED VARIABLES:
%
%                         - Config: [struct] with fields:
%
%                                   - initJointPosOpt: [struct];
%                                   - Optimization: [struct];
%                                   - TurbinesData: [struct];
%                                   - iDyntreeVisualizer: [struct];
%                                   - Simulator: [struct];
%                                   - Model: [struct];
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Dec 2018
    
%% ------------Initialization----------------

% run the script containing the initial conditions for the optimization
run(strcat(['./app/', Config.Simulator.modelFolderName,'/initJointPosOptimization.m']));

% the ironBot urdf model contains all the available turbines. It is necessary
% to create a modified urdf file containing only some turbines
newModelName = generateUrdfModelForTesting(Config.TurbinesData, Config.Model);

% load the reduced model
KinDynModel  = idyn_loadReducedModel(Config.Model.jointList, Config.Model.baseLinkName, Config.Model.modelPath, ...
                                     newModelName, Config.Simulator.wrappersDebugMode); 

% set the initial robot state 
idyn_setRobotState(KinDynModel, Config.initJointPosOpt.w_H_b_init, Config.initJointPosOpt.jointPos_init, ...
                   zeros(6,1), Config.initJointPosOpt.jointVel_init, Config.initJointPosOpt.gravityAcc);

% get the initial pose of the left and right foot
%
% TODO: generalize to any link
%
w_H_lFootInit = idyn_getWorldTransform(KinDynModel,'l_sole');
w_H_rFootInit = idyn_getWorldTransform(KinDynModel,'r_sole');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% nonlinear optimization %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initial optimization vector uInit
[uInit, uDes]        = computeInitialConditionsAndReferences(Config.initJointPosOpt.w_H_b_init, Config.initJointPosOpt.jointPos_init, ...
                                                             Config.initJointPosOpt.jetIntensities_init);

% nonlinear constraints function
nonLinearConstraints = @(u) computeNonLinearConstraints(u, KinDynModel, Config.initJointPosOpt.gravityAcc, ...
                                                        Config.TurbinesData, w_H_lFootInit, w_H_rFootInit);

% compute the cost function
costFunction = @(u) transpose(computeMomentumDerivative(u, KinDynModel, Config.initJointPosOpt.gravityAcc, Config.TurbinesData)) * ...
                    Config.Optimization.WeightsMatrixMomentum * (computeMomentumDerivative(u, KinDynModel, Config.initJointPosOpt.gravityAcc, Config.TurbinesData)) + ...
                    transpose((u-uDes)) * Config.Optimization.WeightsMatrix * (u-uDes);

% set uptions of the nonlinear optimization
options = setoptimoptions('MaxFunEvals',70000,'MaxIter',70000);
    
disp('[runJointPosOptimization]: running optimization...')
    
% nonlinear optimization
[uStar, fval, exitflag, output] = minimize(costFunction, uInit, [], [], [], [], Config.Optimization.lowerBound, ...
                                           Config.Optimization.upperBound, nonLinearConstraints, options);   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% delete the urdf model that has been created for the test
delete([Config.Model.modelPath, newModelName])
    
disp(['[runJointPosOptimization]: removing ', newModelName])

% visualize the joint position
if Config.Simulator.showVisualizer
    
    % convert u to the model state (required for the visualizer)
    ndof  = idyn_getNrOfDegreesOfFreedom(KinDynModel);
    njets = Config.TurbinesData.njets;
    
    [basePos, baseRot_rpy, jointPos, ~] = vectorDemux(uStar, [3;3;ndof;njets]);
  
    w_R_b = rotationFromRollPitchYaw(baseRot_rpy);
    w_H_b = [w_R_b, basePos;
              0   0   0  1]; 
  
    % run the visualizer
    runVisualizer(jointPos, w_H_b(:), Config.iDyntreeVisualizer.time, Config.iDyntreeVisualizer.createVideo, ...
                  KinDynModel, Config.iDyntreeVisualizer, Config.Simulator);   
end

% compare the momentum derivatives
initialMomentumDerivative = computeMomentumDerivative(uInit, KinDynModel, Config.initJointPosOpt.gravityAcc, Config.TurbinesData);
finalMomentumDerivative   = computeMomentumDerivative(uStar, KinDynModel, Config.initJointPosOpt.gravityAcc, Config.TurbinesData);

disp('Momentum derivative: [initial, final]')
disp(num2str([initialMomentumDerivative,finalMomentumDerivative]))
disp('[runJointPosOptimization]: optimization finished.')