% OPENEXISTINGSIMULATION opens an existing simulation from MAT file and runs 
%                        the visualization tools (if available). 
%
%                        REQUIRED VARIABLES:
%
%                        - Config: [struct] with fields:
%
%                                  - Simulator: [struct];
%                                  - Model: [struct];
%                                  - Visualization: [struct];
%                                  - iDyntreeVisualizer: [struct];
%                                  - SimulationOutput: [struct];
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------
clear variables
close('all','hidden')
clc 

% if TRUE, also plot simulation results (if possible)
showSimulationResults = true;

% if TRUE, the simulation video and pics are saved again
saveSimulationPics    = false;
saveSimulationVideo   = false;

% MAT files are expected to be stored in the 'DATA' folder
if ~exist('./DATA','dir')
    
    error('[openExistingSimulation]: no "DATA" folder found.')
else
    disp('[openExistingSimulation]: ready to load a MAT file.')
    experimentsList = dir('DATA/*.mat');
    expList         = cell(size(experimentsList,1),1);
    
    for k = 1:size(experimentsList,1)
        
        expList{k}  = experimentsList(k).name;
    end
    [expNumber, ~]  = listdlg('PromptString','Choose a MAT file:', ...
                              'ListString',expList, ...
                              'SelectionMode','single', ...
                              'ListSize',[250 150]);                                
    if ~isempty(expNumber)

        % open the experiment
        load(['./DATA/',expList{expNumber}]);
        
        % set savePictures and activateVideoMenu FALSE by default
        Config.Simulator.savePictures = false;
        Config.Simulator.activateVideoMenu = false;
        
        if saveSimulationPics
            
            Config.Simulator.savePictures = true; %#ok<UNRCH>
        end
        if saveSimulationVideo
            
            Config.Simulator.activateVideoMenu = true; %#ok<UNRCH>
        end
            
        % show results (if available)
        if showSimulationResults

            % add required paths
            addpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/core-functions']))
            addpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/utility-functions']))
            addpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/wrappers']))
            addpath(genpath([Config.Simulator.LocalPaths.pathToExternal,'/FEX-function_handle']))
            addpath(genpath([Config.Simulator.LocalPaths.pathToModels,'/models/', Config.Simulator.modelFolderName]));
            addpath('./src');

            % run the model initialization script
            initModelHandle = function_handle(['app/',Config.Simulator.modelFolderName,'/init_', Config.Simulator.modelFolderName, '.m']);
            initModelHandle();
    
            % load the reduced model (it cannot be properly stored in MAT files)
            KinDynModel = idyn_loadReducedModel(Config.Model.jointList,Config.Model.baseLinkName,Config.Model.modelPath, ...
                                                Config.Model.modelName,Config.Simulator.wrappersDebugMode);
    
            if Config.Simulator.showSimulationResults || Config.Simulator.showVisualizer
                
                % open the visualization menu
                openVisualizationMenu(KinDynModel,Config.Visualization,Config.iDyntreeVisualizer, ...
                                      Config.Simulator,Config.SimulationOutput,Config.Simulator.showSimulationResults,Config.Simulator.showVisualizer);
            end
 
            % remove paths
            rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/core-functions']))
            rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/utility-functions']))
            rmpath(genpath([Config.Simulator.LocalPaths.pathToCore,'/wrappers']))
            rmpath(genpath([Config.Simulator.LocalPaths.pathToExternal,'/FEX-function_handle']))
            rmpath(genpath([Config.Simulator.LocalPaths.pathToModels,'/models/', Config.Simulator.modelFolderName]));
            rmpath('./src');
            
            % delete the temporary model and folder
            delete([Config.Model.modelPath, Config.Model.modelName]);

            if exist('TEMP','dir')
                rmdir('TEMP');
            end
        end
    end
end
disp('[openExistingSimulation]: closing.')