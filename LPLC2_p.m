% /*********************************************************
%  ** function LPLC2_p()
%  ** Parallelingly calls the LPLC2.
%  ** GENERAL FEATURES HERE

%  * AUTHOR:  
%  *     Mu Hua                                                                                            

%  * INPUT:  
%  *    1) 
%  *    2) 
%  *    3) 
%  *    4) 

%  * OUTPUT:  
%  *    1) 
%  *    2) 

%  * HISTORY:  
%  *    20220224 1711 Scripted.

%  * WARNINGS: 
%  *    1) 
%  *    2) 

%  *===================================*/
function LPLC2_p()
tic
        core = 6;
        
        [visualSignals, numFile] = getFileNames('Z:\#MatlabProjects\mhua\lplc2\ultraselect\Comparative\simulation');
    
        LPLC2_parallel = parpool(core);

        parfor countFile = 1:numFile
            
            inputVideo = visualSignals(countFile);
    
            LPLC2(inputVideo);
    
        end

        delete(LPLC2_parallel);
    
toc
end