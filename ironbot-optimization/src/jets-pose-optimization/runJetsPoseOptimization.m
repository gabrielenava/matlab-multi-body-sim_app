% RUNJETSPOSEOPTIMIZATION runs the jets pose optimization simulation.
%
%                         REQUIRED VARIABLES:
%
%                         - Config: [struct] with fields:
%
%                                   - initJetsPoseOpt: [struct];
%                                   - iDyntreeVisualizer: [struct];
%                                   - Simulator; [struct].
%                                   - Model; [struct].
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------

% run the script containing the initial conditions for the jets pose optimization demo
run(strcat(['./app/',Config.Simulator.modelFolderName,'/initOptimizeJetsPose.m']));

cont          = 1;
avg_condNum_P = [];

% save the average condition numbers
if Config.Simulator.saveSimulationResults
    
    dataFileName = saveSimulationData(Config.Visualization,Config.Simulator,'init');
end

% loop on the available tests
for testNumber = Config.initJetsPoseOpt.testNumbersVector

    disp(['[runJetsPoseOptimization]: running test number ', num2str(testNumber)])
    
    % generate the turbines data structure according to the current test
    TurbinesData = switchModel(testNumber);

    % create a modified urdf model that contains only the selected turbines
    newModelName = generateUrdfModelForTesting(TurbinesData,Config.Model);
    
    % load the reduced model
    KinDynModel  = idyn_loadReducedModel(Config.Model.jointList,Config.Model.baseLinkName,Config.Model.modelPath, ...
                                         newModelName,Config.Simulator.wrappersDebugMode); 

    % move the robot joints to measure how the condition number varies
    avg_condNum_P(cont) = moveRobotJoints(KinDynModel,TurbinesData,Config.initJetsPoseOpt); %#ok<SAGROW>
    
    % delete the urdf model that has been created for the i-th test
    delete([Config.Model.modelPath,newModelName])
    
    disp(['[runJetsPoseOptimization]: removing ',newModelName])
    
    cont = cont + 1;
end

% plot the average condition numbers
if Config.Simulator.showSimulationResults
    
    dataNameList                       = Config.Visualization.vizVariableList;
    figureSettingsList                 = Config.Visualization.figureSettingsList;
    DataForVisualization.t             = 0:0.01:Config.initJetsPoseOpt.tMax;
    DataForVisualization.avg_condNum_P = zeros(length(avg_condNum_P),length(DataForVisualization.t));
    
    for k = 1:length(avg_condNum_P)
        
        DataForVisualization.avg_condNum_P(k,:) = avg_condNum_P(k).*ones(length(DataForVisualization.t),1);
    end
    plotSimulationData(dataNameList,figureSettingsList,DataForVisualization,Config.Visualization,Config.Simulator);
end

% save the average condition numbers
if Config.Simulator.saveSimulationResults
    
    Config.Visualization.updatedVizVariableList = Config.Visualization.vizVariableList;
    Config.Visualization.dataFileName           = dataFileName;
    Config.Visualization.dataForVisualization   = DataForVisualization;
    
    dataFileName = saveSimulationData(Config.Visualization,Config.Simulator,'update');
end

disp('[runJetsPoseOptimization]: optimization finished.')