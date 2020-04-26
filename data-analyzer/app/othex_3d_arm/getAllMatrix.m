% Compute the allocation matrix of Othex propellers   
T_wrench_t = [0; 0; kf; 0; 0; kd];

base_H_T1  = iDynTreeWrappers.getRelativeTransform(KinDynModel,'root_link','frame_prop_1');
base_H_T2  = iDynTreeWrappers.getRelativeTransform(KinDynModel,'root_link','frame_prop_2');
base_H_T3  = iDynTreeWrappers.getRelativeTransform(KinDynModel,'root_link','frame_prop_3');
base_H_T4  = iDynTreeWrappers.getRelativeTransform(KinDynModel,'root_link','frame_prop_4');
base_H_T5  = iDynTreeWrappers.getRelativeTransform(KinDynModel,'root_link','frame_prop_5');
base_H_T6  = iDynTreeWrappers.getRelativeTransform(KinDynModel,'root_link','frame_prop_6');

base_X_T1 = fromHtoX(base_H_T1);
base_X_T2 = fromHtoX(base_H_T2);
base_X_T3 = fromHtoX(base_H_T3);
base_X_T4 = fromHtoX(base_H_T4);
base_X_T5 = fromHtoX(base_H_T5);
base_X_T6 = fromHtoX(base_H_T6);
  
AllocationMatrix = [base_X_T1*T_wrench_t,base_X_T2*T_wrench_t,base_X_T3*T_wrench_t, ...
                    base_X_T4*T_wrench_t,base_X_T5*T_wrench_t,base_X_T6*T_wrench_t];
               
function X = fromHtoX(H)

    X = [H(1:3,1:3),                    zeros(3);
         wbc.skew(H(1:3,4))*H(1:3,1:3), H(1:3,1:3)];
end
