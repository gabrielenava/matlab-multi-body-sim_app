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

% Load the dataset
load('./exp/datasetCla_38.mat')

% Extract data
time     = intentionData.pouring.data(2).time;
w_H_b    = intentionData.pouring.data(2).opt_G_H_base{1};
jointPos = intentionData.pouring.data(2).opt_sInDeg'*pi/180;

% Re-orient the base rotation w.r.t. world frame
wRotated_H_w          = [wbc.rotationFromRollPitchYaw([0,0,0]*pi/180), zeros(3,1);
                         0  0  0 1];   
basePosAndRot_rotated = wRotated_H_w*w_H_b;  
w_H_b                 = basePosAndRot_rotated(:);

% Specify a desired frame rate for the playback
playback_frameRate    = 1;
