function [M_c, g_T_b] = getCentrTransf(M, xCoM, xBase)

    % GETCENTRTRANSF gets the transformation matrix from the frame B[W] to 
    %                the frame G[W] (centroidal coordinates), and the mass 
    %                matrix in centroidal coordinates.
    %
    % FORMAT:  [M_c, g_T_b] = getCentrTransf(M, xCoM, xBase)
    %
    % INPUTS:  - M: [6+ndof x 6+ndof] free floating mass matrix;
    %          - xCoM: [3 x 1] CoM position in world coordinates;
    %          - xBase: [3 x 1] base link position in world coordinates;
    %
    % OUTPUTS: - M_c: [6 x 6] floating base mass matrix in centroidal coordinates.
    %          - g_T_b: [6+ndof x 6+ndof] from base to centroidal coordinates.
    %
    % Author : Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Dec 2018

    %% ------------Initialization----------------

    r       = xCoM -xBase;
    X       = [eye(3),   wbc.skew(r)';
               zeros(3), eye(3)];
           
    Mbs     = M(1:6,7:end);
    Mb      = M(1:6,1:6);
    Js      = X*(Mb\Mbs);
    ndof    = size(Mbs,2);

    g_T_b   = [X,             Js;
               zeros(ndof,6), eye(ndof)];
     
    % Inverse of the transformation
    invT    = eye(ndof+6)/g_T_b;
    invTt   = eye(ndof+6)/(g_T_b');

    % Get the full mass matrix in centroidal coordinates
    M_c_tot = invTt*M*invT;
    
    % Get the "total" mass matrix
    M_c     = M_c_tot(1:6,1:6);    
end