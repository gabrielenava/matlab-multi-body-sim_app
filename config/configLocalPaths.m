function LocalPaths = configLocalPaths()

    % CONFIGLOCALPATHS configures the local paths to be used by the simulator 
    %                  in order to point the folders where the required 
    %                  libraries and models are.
    %
    % FORMAT:  LocalPaths = configLocalPaths()
    %
    % OUTPUTS: LocalPaths = [struct] with fields:
    %
    %                       - pathToSuperbuildInstall [string];
    %                       - pathToSuperbuildSources [string];
    %                       - pathToModels [string];
    %                       - pathToExternal [string].
    %
    % Author: Gabriele Nava (gabriele.nava@iit.it)
    % Genova, Dec 2018
    
    %% ------------Initialization----------------
    
    % path to the superbuild "install" folder. If you did not installed the
    % repository through the "mbs_superbuild", the path will be empty.
    currentPath      = pwd;
    splitCurrentPath = strsplit(currentPath,'/');
    isSuperbuild     = strcmp(splitCurrentPath,'mbs_superbuild');
    
    % loop to create the path to the superbuild "install" folder
    LocalPaths.pathToSuperbuildInstall = '';
    LocalPaths.pathToSuperbuildSources = '';
    index = 0;
    
    for k = 1:length(isSuperbuild)
        
        if isSuperbuild(k) == 1
            
            index = k;
        end
    end
                
    if index > 0
        
        for kk = 1:index
            
            if ~isempty(splitCurrentPath{kk})
            
                % path to the superbuild source folder
                LocalPaths.pathToSuperbuildSources = [LocalPaths.pathToSuperbuildSources,'/',splitCurrentPath{kk}];
            end
        end
        
        % path to the superbuild install folder
        LocalPaths.pathToSuperbuildInstall = [LocalPaths.pathToSuperbuildSources,'/build/install'];  
    end
    
    % if the path to the superbuild install folder is empty, it is required
    % to manually specify the path to the "mbs_models" and "external" folders.
    % If instead the repository has been installed through the superbuild,
    % these paths are automatically created.
    LocalPaths.pathToModels = LocalPaths.pathToSuperbuildInstall;
    
    if isempty(LocalPaths.pathToSuperbuildInstall)
        
        warning('[configLocalPaths]: please manually set the path to the "mbs_models" folders.');
        
        % USER CAN EDIT HERE
    end
    
    % path to the external sources. If the repo has been installed using
    % the superbuild, the path to the "external" folder inside the superbuild 
    % source folder is automatically added
    if exist([LocalPaths.pathToSuperbuildSources,'/external'],'dir') > 0
        
        LocalPaths.pathToExternal = [LocalPaths.pathToSuperbuildSources,'/external'];
    else
        % USER CAN EDIT HERE
        
        warning('[configLocalPaths]: please manually set the path to the "external" sources (if there is any).');
        LocalPaths.pathToExternal = '';
    end 
end
