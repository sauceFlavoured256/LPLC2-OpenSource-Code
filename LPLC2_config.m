% /*********************************************************
%  ** function paraInitialize_lplc(varargin)
%  ** Parameters initialization for lplc2
%  ** 

%  * AUTHOR:  
%  *     Mu Hua                                                                                            

%  * INPUT:  
%  *    1) Anything unrelated you want will not impact.
%  *    2) 
%  *    3) 
%  *    4) 

%  * OUTPUT:  
%  *    1) In the form of cell, the first col is paraName, the second is value. 
%  *    2) 

%  * HISTORY:  
%  *    20210820 1300 Scripted.
%  *    20220224 1707 General maintenance.

%  * WARNINGS: 
%  *    1) Numbers of col currently mannually set to a const.
%  *    2) 

%  *===================================*/







function paraCell =  LPLC2_config(varargin)
%%%%%%%%%%%%%%%%%%Below parameters make up a cell which will be saved laterly. No need to enter parameters.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%All other parameters will be added later after gene_delay. This cell will be saved.
numPara = 21;
paraNameCell = cell(numPara,1);
paraValueCell = cell(numPara,1);
paraCell = cell(numPara+4, 2);

paraNameCell{1} = 'alphaDiffPre';  % alphaDiffPre_i = (1+exp(i))^(-1); i = 1:np; np = 2;
paraValueCell{1} = 0.2689;

paraNameCell{2} = 'alphaDiffPre2'; % alphaDiffPre_i = (1+exp(i))^(-1); i = 1:np; np = 2;
paraValueCell{2} = 0.1192;

paraNameCell{3} = 'alphaChannel'; % a residual factor for both ON and OFF channels.
paraValueCell{3} = 0.1;

paraNameCell{4} = 'alphaLGMD'; % [0.5,1)
paraValueCell{4} = 1;

paraNameCell{5} = 'alphaSpike'; % a scalor to resize spike. 
paraValueCell{5} = 4;

paraNameCell{6} = 'deltaC'; % a small real number
paraValueCell{6} = 0.01;

paraNameCell{7} = 'nsp'; % Collision threshold
paraValueCell{7} = 7;

paraNameCell{8} = 'nts'; % Time window belongs in [6,8], only early Nt frames counted for spike_index
paraValueCell{8} = 6;

paraNameCell{9} = 'thetaON'; % For s_ON, one of three scalors in S layer
paraValueCell{9} = 0.5;

paraNameCell{10} = 'thetaOFF'; % For s_OFF, one of three scalors in S layer
paraValueCell{10} = 1;
 
paraNameCell{11} = 'thetaChannel'; % % For s_ON & s_OFF, one of three scalors in S layer
paraValueCell{11} = 1;

paraNameCell{12} = 'threPM'; % Potential Meditation threshold
paraValueCell{12} = 10;

paraNameCell{13} = 'threSFA'; % Local threshold for SFA mechanism belonging in [500,1000]
paraValueCell{13} = 500;

paraNameCell{14} = 'threSpike';
paraValueCell{14} = 0.7;

paraNameCell{15} = 'threGLayer';
paraValueCell{15} = 15;

paraNameCell{16} = 'tDW'; % Natural decay length
paraValueCell{16} = 7;

paraNameCell{17} = 'w3'; % bias baseline in ON channel
paraValueCell{17} = 1;

paraNameCell{18} = 'w4'; % bias baseline in OFF channel
paraValueCell{18} = 0.5;

paraNameCell{19} = 'kernelCoeffi';
paraValueCell{19} = (1/9) .* [1 1 1
                                                   1 1 1
                                                   1 1 1];

paraNameCell{20} = 'kernelON';
paraValueCell{20} =  [0.25    0.5    0.25
                                       0.5       2       0.5
                                       0.25    0.5    0.25];

paraNameCell{21} = 'kernelOFF';
paraValueCell{21} = [0.125    0.25    0.125
                                      0.25        1      0.25   
                                      0.125    0.25   0.125];
                            

for i = 1 : numPara
paraCell{i,1} = paraNameCell{i};
paraCell{i,2} = paraValueCell{i};

end
end