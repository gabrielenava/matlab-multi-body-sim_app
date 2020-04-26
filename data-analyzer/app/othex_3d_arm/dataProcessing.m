% DATAPROCESSING formats data in a format that can be played-back by the 
%                iDyntree visualizer.
%
%                EXPECTED VARIABLES:
%
%                time: [n x 1] vector of n time instants;
%                w_H_b: [16 x n] or [16 x 1] column vecotrization of the
%                        transformation matrix from world to base frame;
%                jointPos: [nDof x n] or [1 x n] vector of joint positions;
%                playback_framerate: framerate of the simulator.
%
% Author: Gabriele Nava (gabriele.nava@iit.it)
% Genova, Nov 2018
    
%% ------------Initialization----------------

% Load the dataset. WARNING: the dataset should not contain a variable 
% called 'Config' or it will be overwritten!
load('./exp/exp1_disturbanceFF.mat')

% Get the base pose and the joints positions
basePos  = basePos_DATA.signals(1).values;
baseRot  = baseRotRPY_DATA.signals(1).values*pi/180;
jointPos = jointPos_DATA.signals(1).values*pi/180;
time     = time_Genom.signals.values;
w_H_b    = zeros(16,size(basePos,1));

% Update the base postion w.r.t. world frame
for k = 1:size(basePos,1)
    
    basePosAndRot = [wbc.rotationFromRollPitchYaw(baseRot(k,:)), (basePos(k,:)-basePos(1,:)+[0,0,0.75])';
                     0 0 0 1];
    wRotated_H_w  = [wbc.rotationFromRollPitchYaw([0,0,90]*pi/180), zeros(3,1);
                     0  0  0 1];
    basePosAndRot_rotated = wRotated_H_w*basePosAndRot;
    w_H_b(1:16,k)         = basePosAndRot_rotated(:);
end

% Specify a desired frame rate for the playback
playback_frameRate    = 30;