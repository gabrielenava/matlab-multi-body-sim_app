% MYSIMULATION example simulation.
%
%              REQUIRED VARIABLES:
%
%              - Config: [struct] with fields:
%
%                        - Simulator: [struct];
%                        - Model: [struct];
% 
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------

% OPTIONAL: run the script containing the initial conditions for the simulation
run(strcat(['../app/',Config.Simulator.modelFolderName,'/initMySimulation.m'])); 

disp('[mySimulation] example simulation.')