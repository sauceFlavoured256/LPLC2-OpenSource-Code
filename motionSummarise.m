% /*********************************************************
%  ** function outputMatrix = motionSummarise( onChannelMotion, offChannelMotion, cON, cOFF, onIndex, offIndex, coefficientMotion, coefficientContrast) 
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
%  *    20220224 1701 General maintenance.

%  * WARNINGS: 
%  *    1) 
%  *    2) 

%  *===================================*/

function outputMatrix = motionSummarise( onChannelMotion, offChannelMotion, cON, cOFF, onIndex, offIndex, coefficientMotion, coefficientContrast)
   [frameHeight, frameWidth] = size(onChannelMotion);
   outputMatrix = zeros(frameHeight, frameWidth);
   ON = onChannelMotion * coefficientMotion - cON * coefficientContrast;
   OFF = offChannelMotion * coefficientMotion - cOFF * coefficientContrast;
   ON(ON<0) = 0;
   OFF(OFF<0) = 0;
   
for i = 1:frameHeight
    for j = 1:frameWidth
        outputMatrix(i,j) =ON(i,j) ^ onIndex + OFF(i,j) ^ offIndex;
    end
end
end