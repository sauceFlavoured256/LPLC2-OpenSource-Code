% /*********************************************************
%  ** function correspondingMotionDir = motionCorrelate( theDelaySignal,the ChannelSignal,desiredDirection,samplingDistance)   
%  ** desiredMotion belongs to ['uppy', 'downy', 'lefty', 'righty']
%  ** This function calculates motions in the four cardinal directions.

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
%  *    20220224 1700 General maintenance. 

%  * WARNINGS: 
%  *    1) 
%  *    2) 

%  *===================================*/

function correspondingMotionDir = motionCorrelate(theDelaySignal, ...
                                                                                  theChannelSignal, ...
                                                                                  desiredDirection, ...
                                                                                  samplingDistance)

[matrixHeight, matrixWidth] = size(theDelaySignal);                                                                                                          
correspondingMotionDir = zeros([matrixHeight, matrixWidth]);

switch desiredDirection
    case 'uppy'
        sdX = 0;
        sdY = samplingDistance;
    case 'downy'
        sdX = 0;
        sdY = -1 * samplingDistance;
    case 'lefty'
        sdX = -1 * samplingDistance;
        sdY = 0;
    case 'righty'
        sdX = samplingDistance;
        sdY = 0;
end

for i = samplingDistance+1 : matrixHeight - samplingDistance
    for j = samplingDistance+1 : matrixWidth - samplingDistance
        correspondingMotionDir(i,j) = theDelaySignal(i, j) ...
                                                             * theChannelSignal(i, j) ... 
                                                             * theChannelSignal(i+sdX, j+sdY) ...
                                                             - theChannelSignal(i, j) ...
                                                             * theDelaySignal(i+sdX, j+sdY) ...
                                                             * theChannelSignal(i+sdX, j+sdY);
    
    end
end



end