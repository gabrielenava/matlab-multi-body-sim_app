% DATAANALYZER main script for running the data analyzer demo.
%
%                     REQUIRED VARIABLES:
%
%                     - Config: [struct] with fields:
%
%                               - Simulator: [struct];
%                               - Model: [struct];
%                               - initDataAnalysis: [struct];
%
%                               Optional fields:
%
%                               - iDyntreeVisualizer: [struct];
%                               - SimulationOutput: [struct]; (created here)
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------

% run the script containing the initial conditions for the gravity compensation demo
run(strcat(['./app/',Config.Simulator.modelFolderName,'/initDataAnalysis.m']));

% load the reduced model
KinDynModel = iDynTreeWrappers.loadReducedModel(Config.Model.jointList,Config.Model.baseLinkName,Config.Model.modelPath, ...
                                                Config.Model.modelName,Config.Simulator.wrappersDebugMode); 

% get the robot trajectories                                            
run(strcat(['./app/',Config.Simulator.modelFolderName,'/dataProcessing.m']));

% set the initial robot state 
iDynTreeWrappers.setRobotState(KinDynModel,reshape(w_H_b(:,1),4,4),jointPos(1,:)', ...
                               zeros(6,1),zeros(length(Config.Model.jointList),1),Config.initDataAnalysis.gravityAcc)
 
% run the iDyntree visualizer
jointPos = jointPos(1:playback_frameRate:end,:);
w_H_b    = w_H_b(:,1:playback_frameRate:end);
time     = time(1:playback_frameRate:end);

runVisualizer(jointPos',w_H_b,time,Config.Simulator.createVideo,KinDynModel,Config.iDyntreeVisualizer,Config.Simulator)      
