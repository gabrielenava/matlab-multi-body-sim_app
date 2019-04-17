function chiDot = computeSystemVelocities(t,chi,KinDynModel,Config)

    % COMPUTESYTEMVELOCITIES computes the base and joints velocities of a 
    %                        floating base system floating in zero
    %                        gravity. The control inputs are the joints
    %                        velocities.
    %
    %                        REQUIRED VARIABLES:
    %
    %                        - Config: [struct] with fields:
    %
    %                                  - Simulator: [struct];
    %                                  - Visualization: [struct]; (partially created here)
    %                                  - initMomCons: [struct];
    %                                  - integration: [struct];
    %
    % FORMAT:  chiDot = computeSystemVelocities(t,chi,KinDynModel,Config)
    %
    % INPUTS:  - t: current integration time step;
    %          - chi: [7 + ndof x 1] current robot state. Expected format:
    %                 chi = [basePose_qt; jointPos];
    %          - KinDynModel: [struct] contains the loaded model and additional info;
    %          - Config: [struct] collects all the configuration parameters;
    %
    % OUTPUTS: - chiDot: [7 + ndof x 1] current state derivative.
    %
    % Author : Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Dec 2018

    %% ------------Initialization----------------
        
    % update the waitbar
    if ~isempty(Config.integration.wait)
       waitbar(t/Config.integration.tEnd,Config.integration.wait);
    end
    
    % demux the system state
    [basePose_qt,jointPos] = wbc.vectorDemux(chi,[7,KinDynModel.NDOF]);

    % convert the base transform from quaternion to transf. matrix
    w_H_b = fromPosQuatToTransfMatr(basePose_qt);
    
    % update the current system state. All the required dynamics and
    % kinematics quantities do not depend on the base and joints
    % velocities, therefore it shouldn't matter if they are set to zero       
    iDynTreeWrappers.setRobotState(KinDynModel, w_H_b, jointPos, zeros(6,1), zeros(KinDynModel.NDOF,1), ... 
                       Config.initMomCons.gravityAcc);
    
    % get the required dynamics and kinematics quantities
    M            = iDynTreeWrappers.getFreeFloatingMassMatrix(KinDynModel);
    xCoM         = iDynTreeWrappers.getCenterOfMassPosition(KinDynModel);
    w_H_b        = iDynTreeWrappers.getWorldBaseTransform(KinDynModel);
    xBase        = w_H_b(1:3,4);
    
    % compute the measured base velocities, exploiting the momentum

    % conservation: L (momentum) = 0 for all t.
    [M_c, g_T_b] =  getCentrTransf(M, xCoM, xBase);
    McJb         =  M_c*g_T_b(1:6,1:6);
    McJs         =  M_c*g_T_b(1:6,7:end);
    
    % compute the desired joints velocities
    
    if ~Config.initMomCons.USE_MOMENTUM_NULLSPACE
        
        % CASE 1: no null space projection
        jointVel = Config.initMomCons.Amplitude*sin(2*pi*t*Config.initMomCons.Frequency)*ones(KinDynModel.NDOF,1);
    else
        % CASE 2: with null space projection
        NullMcJs = eye(KinDynModel.NDOF)-pinv(McJs,1e-6)*McJs;
        jointVel = NullMcJs*Config.initMomCons.Amplitude*sin(2*pi*t*Config.initMomCons.Frequency)*ones(KinDynModel.NDOF,1);
    end
    
    % compute the base velocities
    baseVel      = -McJb\McJs*jointVel;
    
    % compute the state derivative
    
    % base angular velocity. Expected velocity for quaternion derivative:
    % b_omega_b (body frame) (TO BE VERIFIED)
    b_omega_b    = transpose(w_H_b(1:3,1:3))*baseVel(4:6);
    
    % quaternion derivative
    k            = 1;
    qtDot_base   = quaternionDerivative(basePose_qt(4:end), b_omega_b, k);
    
    % state derivative
    chiDot       = [baseVel(1:3); qtDot_base; jointVel];
    
    % variables for visualization (momentum)
    L            = McJb*baseVel + McJs*jointVel; %#ok<NASGU>
    
    % update the MAT file that contains the data to plot
    if Config.Simulator.showSimulationResults || Config.Simulator.saveSimulationResults

        Config.Visualization.dataForVisualization   = struct;
        Config.Visualization.updatedVizVariableList = {};
        cont = 1;
        
        for k = 1:length(Config.Visualization.vizVariableList)
            
            if strcmp(Config.Visualization.vizVariableList{k},'Config') || strcmp(Config.Visualization.vizVariableList{k},'KinDynModel')
                
                % unpredictable things may happen if the user tries to save
                % the "core" variables Config and KinDynModel during integration
                error('[computeSystemVelocities]: "Config" and "KinDynModel" are reserved variables and cannot be saved in the MAT file.')
            end
                
            % the variables whose name is specified in the "vizVariableList" 
            % must be accessible from this fuction, or the corresponding
            % variable name in the list is removed.
            if exist(Config.Visualization.vizVariableList{k},'var')
                 
                Config.Visualization.updatedVizVariableList{cont} = Config.Visualization.vizVariableList{k};
                Config.Visualization.dataForVisualization.(Config.Visualization.vizVariableList{k}) = eval(Config.Visualization.vizVariableList{k});
                cont = cont +1;
            end
        end    
        % update the MAT file with new data
        [~] = saveSimulationData(Config.Visualization,Config.Simulator,'update');    
    end
end