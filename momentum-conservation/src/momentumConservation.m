% MOMENTUMCONSERVATION main script for running the momentum conservation demo.
%
%                      REQUIRED VARIABLES:
%
%                      - Config: [struct] with fields:
%
%                                - Simulator: [struct];
%                                - Model: [struct];
%                                - initMomCons: [struct];
%                                - integration: [struct]; (partially created here)    
%
%                                Optional fields:
%
%                                - Visualization: [struct]; (partially created here)
%                                - iDyntreeVisualizer: [struct];
%                                - SimulationOutput: [struct]; (created here)
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Dec 2018
    
%% ------------Initialization----------------

% run the script containing the initial conditions for the momentum conservation demo
run(strcat(['./app/',Config.Simulator.modelFolderName,'/initMomentumConservation.m']));

% load the reduced model
KinDynModel = idyn_loadReducedModel(Config.Model.jointList,Config.Model.baseLinkName,Config.Model.modelPath, ...
                                    Config.Model.modelName,Config.Simulator.wrappersDebugMode); 

% set the initial robot state 
idyn_setRobotState(KinDynModel, Config.initMomCons.w_H_b_init, Config.initMomCons.jointPos_init, ...
                   Config.initMomCons.baseVel_init, Config.initMomCons.jointVel_init, Config.initMomCons.gravityAcc)
 
% create the initial state vector. For momentum conservation, chi = [basePose; jointPos]
basePose_qt_init  = fromTransfMatrixToPosQuat(Config.initMomCons.w_H_b_init);
chi_init          = [basePose_qt_init; Config.initMomCons.jointPos_init];

% create a MAT file where the data to plot/save are stored
if Config.Simulator.showSimulationResults || Config.Simulator.saveSimulationResults
    
    Config.Visualization.dataFileName = saveSimulationData(Config.Visualization,Config.Simulator,'init');
else
    Config.Visualization.dataFileName = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Momentum conservation test %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Config.integration.showWaitbar
    
    Config.integration.wait = waitbar(0,'Kinematics integration...');
else
    Config.integration.wait = [];
end

% evaluate integration time
c_in = clock;

disp('[momentumConservation]: integration started...')

systemVelFunc = @(t,chi) computeSystemVelocities(t,chi,KinDynModel,Config);
[time,state]  = ode15s(systemVelFunc,Config.integration.tStart:Config.integration.tStep:Config.integration.tEnd,chi_init,Config.integration.options);

disp('[momentumConservation]: integration ended.')

% evaluate integration time
c_out  = clock;
c_diff = getTimeDiffInSeconds(c_in,c_out); %[s]
c_diff = sec2hms(c_diff);                  %[h, m, s]

disp(['[momentumConservation]: integration time: ', ....
     num2str(c_diff(1)),' h ',num2str(c_diff(2)),' m ',num2str(c_diff(3)),' s.'])

if Config.integration.showWaitbar
    
    delete(Config.integration.wait);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Config.Simulator.showVisualizer
    
    % define a new structure for the iDyntree visualizer containing the
    % joints position, base pose and time vector
    Config.SimulationOutput.jointPos = transpose(state(:,8:end));

    for k = 1:length(time)
        
        currentTransfMatrix                = fromPosQuatToTransfMatr(transpose(state(k,1:7)));
        Config.SimulationOutput.w_H_b(:,k) = currentTransfMatrix(:);
    end
    
    Config.SimulationOutput.time = time;
else
    Config.SimulationOutput = [];
end

if Config.Simulator.showSimulationResults || Config.Simulator.showVisualizer
    
    % open the menu for data plotting and/or for running the iDyntree visualizer
    openVisualizationMenu(KinDynModel,Config.Visualization,Config.iDyntreeVisualizer, ...
                          Config.Simulator,Config.SimulationOutput, ...
                          Config.Simulator.showSimulationResults, Config.Simulator.showVisualizer);
end

% delete the current simulation data unless 'saveSimulationResults' is TRUE
if ~Config.Simulator.saveSimulationResults
    
    if exist('DATA','dir') && (exist(['./DATA/',Config.Visualization.dataFileName,'.mat'],'file') == 2)
        
        delete(['./DATA/',Config.Visualization.dataFileName,'.mat']);
        dataDir = dir('DATA');
        disp(['[momentumConservation]: removing file ','./DATA/',Config.Visualization.dataFileName,'.mat'])
        
        if size(dataDir,1) == 2
            
            % data folder is empty. Remove it too.
            rmdir('DATA');  
        end
    end
else
    % append Config structure to the saved data (needed for playback mode)
    DataForVisualization        = matfile(['./DATA/',Config.Visualization.dataFileName,'.mat'],'Writable',true);
    DataForVisualization.Config = Config;
end