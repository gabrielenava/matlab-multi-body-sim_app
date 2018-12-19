% INITVISUALIZATION initializes the visualization settings for all simulations.
%
%                   REQUIRED VARIABLES:
%
%                   - Config: [struct] with fields:
%
%                             - Visualization: [struct]; (created here)
%                             - Simulator; [struct].
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------

if strcmp(Config.Simulator.demoScriptName,'runJetsPoseOptimization')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%% Jets optimization demo %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % this list contains the NAMES of all the variables that it will be
    % possible to plot when the simulation is over
    Config.Visualization.vizVariableList = {'t','avg_condNum_P'};

    % if "activateXAxisMenu" is TRUE, a GUI will appear asking the user to 
    % specify which variable to use as x-axis in the plots between the ones 
    % inside the "vizVariableList". If FALSE, the "defaultXAxisVariableName" 
    % will be used instead. The selected x-axis must respect these conditions:
    %
    % - the variable exists;
    % - the variable "defaultXAxisVariableName" is also inside the "vizVariableList";
    % - the variable is a vector of the same length of the y-axis;
    %
    % if one of the above conditions is not true, the specified x-axis is ignored.
    Config.Visualization.activateXAxisMenu        = true;
    Config.Visualization.defaultXAxisVariableName = 't';

    % general settings
    Settings = struct;
    Settings.lineWidth         = 4;
    Settings.fontSize_axis     = 25;
    Settings.fontSize_leg      = 25;
    Settings.removeLegendBox   = true;
    Settings.legendOrientation = 'vertical';
    Settings.xLabel            = {'Time [s]'};
    
    % time
    Config.Visualization.figureSettingsList{1}.Mode = 'singlePlot';
    Config.Visualization.figureSettingsList{1}.Settings = Settings;
    Config.Visualization.figureSettingsList{1}.Settings.yLabel = {'Time [s]'};
    Config.Visualization.figureSettingsList{1}.Settings.figTitle = {'Integration time'};
    
    % average condition number
    Config.Visualization.figureSettingsList{2} = Config.Visualization.figureSettingsList{1};
    Config.Visualization.figureSettingsList{2}.Settings.yLabel = {'average CondNumber'};
    Config.Visualization.figureSettingsList{2}.Settings.figTitle = {'Average Condition Numbers'};
    Config.Visualization.figureSettingsList{2}.Settings.legendList = {'chest P arms P', ...
                                                                      'chest N arms P', ...
                                                                      'chest P arms N', ...
                                                                      'chest N arms N', ...
                                                                      'legs N arms P', ...
                                                                      'legs N arms N', ...
                                                                      'legs P arms P', ...
                                                                      'legs P arms N', ...
                                                                      'chest P arms P legs P', ...
                                                                      'chest N arms P legs P', ...
                                                                      'chest N arms N legs P', ...
                                                                      'chest N arms N legs N', ...
                                                                      'chest P arms N legs N', ...
                                                                      'chest P arms P legs N', ...
                                                                      'chest N arms P legs N', ...
                                                                      'chest P arms N legs P'};
                                                                  
    % update the legendList according to the number of data to plot
    Config.Visualization.figureSettingsList{2}.Settings.legendList = Config.Visualization.figureSettingsList{2}.Settings.legendList(Config.initJetsPoseOpt.testNumbersVector);
else
    error('[initVisualization]: figures settings not available for the selected demo.')
end