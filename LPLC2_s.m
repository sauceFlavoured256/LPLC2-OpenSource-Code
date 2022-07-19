% /*********************************************************
%  ** GENERAL FEATURES HERE
%  ** GENERAL FEATURES HERE
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
%  *    20220224 1657 General maintenance. Function name switched to LPLC2_s().

%  * WARNINGS: 
%  *    1) 
%  *    2) 

%  *===================================*/



function LPLC2_s()

    [videosToRun, numFile] = getFileNames('Z:\#MatlabProjects\mhua\lplc2\ultraselect\Comparative\simulation');
   
    for countFile = 1: numFile
        
        inputVideoName = videosToRun{countFile};
        
        LPLC2(inputVideoName);
        
    end


end
