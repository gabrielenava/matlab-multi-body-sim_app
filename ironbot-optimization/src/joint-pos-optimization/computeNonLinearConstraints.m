function [c,ceq] = computeNonLinearConstraints(u,KinDynModel,gravAcc,TurbinesData,w_H_lFootInit,w_H_rFootInit)

    % COMPUTENONLINEARCONSTRAINTS computes the nonlinear constraints for the
    %                             joints position optimization.
    %
    % FORMAT:  [c,ceq] = computeNonLinearConstraints(u,KinDynModel,gravAcc,TurbinesData,w_H_lFootInit,w_H_rFootInit)
    %
    % INPUTS:  - u: [6+ndof+njets x 1] optimization variable;
    %          - KinDynModel: a structure containing the loaded model and additional info;
    %          - gravAcc:[3 x 1] vector of the gravity acceleration in the inertial frame;
    %          - TurbinesData: [struct] turbines specifications:
    %
    %                          REQUIRED FIELDS:
    % 
    %                          - njets: [int];
    %
    %          - w_H_lFootInit: [4 x 4] from lFoot to world initial
    %                           transformation matrix;
    %          - w_H_rFootInit: [4 x 4] from rFoot to world initial
    %                           transformation matrix;
    %    
    % OUTPUTS: - c: equation representing the nonlinear inequality
    %               constraints. Format: c(u) < = 0;
    %          - ceq: equation representing the nonlinear equality
    %                 constraints. Format: ceq(u) = 0.
    %
    % Author : Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Dec 2018

    %% ------------Initialization----------------
    
    % nonlinear equality constraints
    ceq   = [];
    
    % turbines and joints data
    njets = TurbinesData.njets;
    ndof  = idyn_getNrOfDegreesOfFreedom(KinDynModel);
    
    % state demux and convert Euler angles in rotation matrix
    [basePos, baseRot, jointPos, ~] = vectorDemux(u, [3;3;ndof;njets]);
    
    w_R_b = rotationFromRollPitchYaw(baseRot);
    w_H_b = [w_R_b, basePos;
             0   0   0  1];
    
    % set the current model state
    idyn_setRobotState(KinDynModel, w_H_b, jointPos, zeros(6,1), zeros(ndof,1), gravAcc);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%% FixedLinks constraints %%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % it is assumed that the two fixed links are the feet
    %
    % TODO: generalize to any fixed link
    %
    % initial feet orientation
    rollPitchYaw_LfootInit = rollPitchYawFromRotation(w_H_lFootInit(1:3,1:3));
    rollPitchYaw_RfootInit = rollPitchYawFromRotation(w_H_rFootInit(1:3,1:3));
    
    % current feet pose
    w_H_lFoot              = idyn_getWorldTransform(KinDynModel,'l_sole');
    w_H_rFoot              = idyn_getWorldTransform(KinDynModel,'r_sole');
    
    % convert to RPY
    rollPitchYaw_Lfoot     = rollPitchYawFromRotation(w_H_lFoot(1:3,1:3));
    rollPitchYaw_Rfoot     = rollPitchYawFromRotation(w_H_rFoot(1:3,1:3));
    
    constraintsLfoot       = [(w_H_lFoot(1:3,4)-w_H_lFootInit(1:3,4));(rollPitchYaw_Lfoot-rollPitchYaw_LfootInit)];
    constraintsRfoot       = [(w_H_rFoot(1:3,4)-w_H_rFootInit(1:3,4));(rollPitchYaw_Rfoot-rollPitchYaw_RfootInit)];
    
    % compute the nonlinear constraints as INEQUALITY constraints. They are 
    % actually equality constraints with a tolerance
    tolerance = 0.001;
    c         = abs([constraintsLfoot; constraintsRfoot])-tolerance;
end