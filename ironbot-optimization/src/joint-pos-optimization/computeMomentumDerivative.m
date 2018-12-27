function LDot = computeMomentumDerivative(u,KinDynModel,gravAcc,TurbinesData)

    % COMPUTEMOMENTUMDERIVATIVE computes the centroidal momentum derivative.
    %
    % FORMAT:  LDot = computeMomentumDerivative(u,KinDynModel,gravAcc,TurbinesData)
    %
    % INPUTS:  - u: [6+ndof+njets x 1] optimization variable;
    %          - KinDynModel: a structure containing the loaded model and additional info;
    %          - gravAcc: [3 x 1] vector of the gravity acceleration in the inertial frame;
    %          - TurbinesData: [struct] turbines specifications:
    %
    %                          REQUIRED FIELDS:
    % 
    %                          - njets: [int];
    %                          - turbineLIst: [cell array of string];
    %                          - turbineAxis: [array of int];
    %    
    % OUTPUTS: - LDot: [6 x 1] centroidal momentum derivative.
    %
    % Author : Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Dec 2018

    %% ------------Initialization----------------
    
    % turbines and joints data
    njets       = TurbinesData.njets;
    turbineList = TurbinesData.turbineList;
    turbineAxis = TurbinesData.turbineAxis;
    ndof        = idyn_getNrOfDegreesOfFreedom(KinDynModel);
    
    % state demux and convert Euler angles in rotation matrix
    [basePos, baseRot, jointPos, jetIntensities] = vectorDemux(u, [3;3;ndof;njets]);
    
    w_R_b = rotationFromRollPitchYaw(baseRot);
    w_H_b = [w_R_b, basePos;
             0   0   0  1];
    
    % set the current model state
    idyn_setRobotState(KinDynModel, w_H_b, jointPos, zeros(6,1), zeros(ndof,1), gravAcc);
    
    % total mass of the system and gravity forces
    M       = idyn_getFreeFloatingMassMatrix(KinDynModel);
    m       = M(1,1);
    mg      = m*gravAcc; 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%% Momentum derivative %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % projector of the thrust forces in the momentum equation

    % iterate to compute matrices A and Lambda_temp
    A       = [];
    l_jets  = [];
    r_jets  = []; 
    w_o_CoM = idyn_getCenterOfMassPosition(KinDynModel);

    for i = 1:length(turbineList)

        % i-th turbine pose
        w_H_j_i   = idyn_getWorldTransform(KinDynModel,turbineList{i});
        w_R_j_i   = w_H_j_i(1:3,1:3);
        w_o_j_i   = w_H_j_i(1:3,4);

        % distances between the jets positions and the CoM
        r_jets    = [r_jets, (w_o_j_i - w_o_CoM)]; %#ok<AGROW>
    
        SkewBar_i = [eye(3);    
                     skew(r_jets(:,i))]; 

        % thrust force axis
        l_jets    = [l_jets, sign(turbineAxis(i))*w_R_j_i(1:3,abs(turbineAxis(i)))]; %#ok<AGROW>

        % compute matrix A
        A         = [A, SkewBar_i*l_jets(:,i)]; %#ok<AGROW>
    end
    
    % momentum derivative
    LDot  = A*jetIntensities + [mg;zeros(3,1)];
end