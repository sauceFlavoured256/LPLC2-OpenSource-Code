% /*********************************************************
%  ** function new_test_lplc2(inputVideoFileName)
%  ** This neural network relalised partially the features of lplc2 nuerons,
%  ** which could generate strongest membrane potentials to approaching 
%  ** motion patterns starting from the heart of the visual field.
%  ** 

%  * AUTHOR:  
%  *     Mu Hua                                                                                            

%  * INPUT:  
%  *    1) inputVideoFileName
%  *    2) 
%  *    3) 
%  *    4) 

%  * OUTPUT:  
%  *    1) Membrane potentials on four cardinal direction.
%  *    2) 

%  * HISTORY:  
%  *    20210827 1749 Scripted.
%  *    20210827 1800 One method of preprocessing receptive field is to be adapted.
%  *    20210827 1801 'The complex synptic pathways onto a looming detector neuron revearled using serial blockface scanning electron microscopy'
%  *    20220224 1655 General maintenance. Function name switched to LPLC2().

%  * WARNINGS: 
%  *    1) Frame-by-frame processing after firstly the subtractions 
%  *        between two continuous frames are obtained completely.
%  *    2) 

%  *===================================*/
% /*
% **                           _ooOoo_
% **                          o8888888o
% **                            88" . "88
% **                              (| -_- |)
% **                             O\ = /O
% **                         ____/`---'\____
% **                          .   ' \\| |// `.
% **                          / \\||| 8 |||// \
% **                        / _||||| -8- |||||- \
% **                          | | \\\ 8 /// | |
% **                        | \_| ''\-8-/'' | |
% **                        \ .-\__ `8` ___/-. /
% **                     ___`. .' /--8--\ `. . __
% **             ."" '< `.___\_<8>_/___.' >'"".
% **                   | | : `- \`.;`\ 8 /`;.`/ - ` : | |
% **                   \ \ `-. \_ __\ /__ _/ .-` / /
% ** ======`-.____`-.___\_____/___.-`____.-'======
% **                               `=---='
% **        
% */

function  LPLC2(inputVideoFileName, varargin)
    
tic



    fileName = char(inputVideoFileName);
    
    inputVideo = VideoReader(fileName);
    
    frameRate = inputVideo.FrameRate;
    frameHeight = inputVideo.Height;
    frameWidth = inputVideo.Width;
    videoLength = inputVideo.NumFrames;
    centroidHeight = floor(frameHeight/2);
    centroidWidth = floor(frameWidth/2);
    
    

    initialMatrix3D = zeros([frameHeight, frameWidth, videoLength]);
    initialMatrix2D = zeros([frameHeight, frameWidth]);
        
    
    frameGraySet = initialMatrix3D;    
    photoreceptor = initialMatrix2D;
    gbPhotoreceptor = initialMatrix3D;

    hONs = initialMatrix2D;
    hOFFs = initialMatrix2D;
    
    compressedONs = initialMatrix2D;
    compressedOFFs = initialMatrix2D;
    delayedONs = initialMatrix2D;
    delayedOFFs = initialMatrix2D;
    
    contrastONs = initialMatrix2D;
    contrastONsResidual = initialMatrix2D;
    contrastOFFs = initialMatrix2D;
    contrastOFFsResidual = initialMatrix2D;
    
    T4s = zeros([frameHeight, frameWidth, 4]);
    tempT4s = zeros([frameHeight, frameWidth, 4]);

    T5s = zeros([frameHeight, frameWidth, 4]);
    tempT5s = zeros([frameHeight, frameWidth, 4]);
    
    lplc2_mag = initialMatrix2D;
    lplc2_dir = initialMatrix2D;
    
    
    % /*
    % **NOTE: this matrix needs to be check in terms of DIMENSION.
    % */
    lplc2_region =zeros([1, 4]);
    motionMatrix = zeros([frameHeight, frameWidth, 4]);
    
    
    
    
    radialBias = generateRadialBias(frameHeight/frameWidth, 1, frameHeight, frameWidth, 3 * frameHeight/frameWidth, 3);

    
    gauBlurKernel_1 = generateGaussianKernel(1,1,1);
    gauBlurKernel_2 = generateGaussianKernel(2,2,2);
    
    kernelContrast = generateGaussianKernel(5,5,5);
    
    kernelContrastVision = ones(3,3);
    
    tau_lp = 30;
    t4_lp = 30;
    t5_lp = 30;
    tInterval = 1000/frameRate;
    timeLength = 10;
    
    tmpSum = 0;
    weightDelay = tInterval/(tInterval + tau_lp);
    weightDelayT4 = tInterval/(tInterval + t4_lp);
    weightDelayT5 = tInterval/(tInterval + t5_lp);
    sd = 1;
    exp_ON = 0.9;
    exp_OFF = 0.5;
    coef_contrast = 1;
    coef_motion = 1;
    maxMotion = 0;

    matrixMP = zeros([1,videoLength-1]);
    matrixCardinal = zeros([videoLength, 4]);
    
    % /*
    % ** Read all frames from the input Video file as a 3-D matrix.
    % ** Graylization.
    % */
    for frameCount = 1: videoLength
        
        tempFrame = read(inputVideo, frameCount);
        
        [signalNoiseRatio, frameGraySet( : , : , frameCount)] = preprocess(tempFrame);
            
    end
    
    % /*
    % ** The photoreceptor layer calculation and Gaussian blurring all photoreceptors output.
    % ** The length should be one frame less than videoLength.
    % ** FIRST RETAINED
    % */
    for frameCount = 1: videoLength - 1
        
        photoreceptor = getCertainFrame(frameGraySet, frameCount + 1) ...
                                    - getCertainFrame(frameGraySet, frameCount);
                   
        gbPhotoreceptor(: , : , frameCount) = gaussianBlur(photoreceptor, gauBlurKernel_1, gauBlurKernel_2);
        
    end   

    % /*
    % ** MAIN PROCESSING
    % */
    for frameCount = 2 : videoLength - 1
        
        % /*
        % ** Halfwave rectifying for both ON and OFF channels.
        % ** hONs and hOFFs are output here as two 2D matrices.
        % */
        hONs = halfwave(1, getCertainFrame(gbPhotoreceptor, frameCount), hONs);
        hOFFs = halfwave(0, getCertainFrame(gbPhotoreceptor, frameCount), hOFFs);
        
        % /*
        % ** Fill out the ONs and OFFs 3D matrix. 
        % ** Length should be the same as photoreceptor layer, videoLength - 1.
        % ** FIRST ABANDONED
        % */
%         ONs( : , : , frameCount) = hONs;
%         OFFs( : , : , frameCount) = hOFFs;
        
        % /*
        % ** Signal compression with in both ON and OFF channels.
        % ** Length should be the same as photoreceptor layer, videoLength.
        % ** FIRST ABANDONED
        % */
        compressedONs = convolute(hONs, 0, kernelContrast, 2, 1);
        compressedOFFs = convolute(hOFFs, 0 , kernelContrast, 2 ,1);
        
%         compressedONs = tanh(hONs/(10+compressedONs));
%         compressedOFFs = tanh(hOFFs/(10+compressedOFFs));
        
        
        delayedONs = lowPass(compressedONs, delayedONs, weightDelay);
        delayedOFFs = lowPass(compressedOFFs, delayedOFFs, weightDelay);    

        % /*
        % ** Contrast vision
        % ** Length should be the same as photoreceptor layer, videoLength.
        % ** FIRST ABANDONED
        % */
        tempONs = convolute(compressedONs, 0 , kernelContrastVision, 2 , 0);
        tempOFFs = convolute(compressedOFFs , 0 , kernelContrastVision, 2, 0);
        
        contrastONs = abs(compressedONs - 0.125 * (tempONs-compressedONs));
        contrastOFFs = abs(compressedOFFs - 0.125 * (tempOFFs - compressedOFFs));
        
        % /*
        % ** Obtain final output of both channels.
        % */        
        c_ON = contrastONs - contrastONsResidual;
        c_OFF = contrastOFFs - contrastOFFsResidual;
        
        contrastONsResidual = contrastONs;
        contrastOFFsResidual = contrastOFFs;
        
        % /*
        % ** Motion correlation.
        % ** pixel-wise operation
        % */
        for y = 1: frameHeight
                
                biasDown = y + sd;
                biasUp = y - sd;
            
                % /*
                % ** Border check
                % */
                if biasDown > frameHeight
                    biasDown = frameHeight;
                end
                
                if biasUp < 1
                    biasUp = 1;
                end
                
            for x = 1 : frameWidth
                

                biasRight = x + sd;
                biasLeft = x - sd;
                
                % /*
                % ** Border check
                % */b
                if biasRight > frameWidth
                    biasRight = frameWidth;
                end
                
                if biasLeft < 1
                    biasLeft = 1;
                end
                

            
%                 % /*
%                 % ** Rightward motion.
%                 % */
%                 tempT4s(y,x, 1) = compressedONs(y, x) * compressedONs(y, biasRight) * radialBias(y,x) ...
%                        * (delayedONs(y, x) - delayedONs(y, biasRight));
%                 tempT5s(y,x, 1) = compressedOFFs(y, x) * compressedOFFs(y, biasRight) * radialBias(y,x) ...
%                        * (delayedOFFs(y, x) - delayedOFFs(y, biasRight));
%                    
%                 % /*
%                 % ** Leftward motion
%                 % */
%                 tempT4s(y,x, 2) = compressedONs(y, x) * compressedONs(y, biasLeft) * radialBias(y,x) ...
%                        * (delayedONs(y, x) - delayedONs(y, biasLeft));
%                 tempT5s(y,x, 2) = compressedOFFs(y, x) * compressedOFFs(y, biasLeft) * radialBias(y,x) ...
%                       * (delayedOFFs(y, x) - delayedOFFs(y, biasLeft));
%                   
%                 % /*
%                 % ** Downward motion
%                 % */
%                 tempT4s(y,x, 3) = compressedONs(y, x) * compressedONs(biasDown, x) * radialBias(y,x) ...
%                        * (delayedONs(y, x) - delayedONs(biasDown, x));
%                 tempT5s(y,x, 3) = compressedOFFs(y, x) * compressedOFFs(biasDown, x) * radialBias(y,x) ...
%                       * (delayedOFFs(y, x) - delayedOFFs(biasDown, x));
%             
%                 % /*
%                 % ** Upward motion
%                 % */
%                 tempT4s(y,x, 4) = compressedONs(y, x) * compressedONs(biasUp, x) * radialBias(y,x) ...
%                        * (delayedONs(y, x) - delayedONs(biasUp, x));
%                 tempT5s(y,x, 4) = compressedOFFs(y, x) * compressedOFFs(biasUp, x) * radialBias(y,x) ...
%                       * (delayedOFFs(y, x) - delayedOFFs(biasUp, x));
                tempT4s(y,x,1) = radialBias(y,x) *(delayedONs(y,x) * compressedONs(y,x) *compressedONs(y,biasRight) - compressedONs(y,x) * delayedONs(y,biasRight) *compressedONs(y,biasRight));
                tempT4s(y,x,2) = radialBias(y,x) *(delayedONs(y,x) * compressedONs(y,x) *compressedONs(y,biasLeft) - compressedONs(y,x) * delayedONs(y,biasLeft) *compressedONs(y,biasLeft));
                tempT4s(y,x,3) = radialBias(y,x) *(delayedONs(y,x) * compressedONs(y,x) *compressedONs(biasDown,x) - compressedONs(y,x) * delayedONs(biasDown,x) *compressedONs(biasDown,x));
                tempT4s(y,x,4) = radialBias(y,x) *(delayedONs(y,x) * compressedONs(y,x) *compressedONs(biasUp,x) - compressedONs(y,x) * delayedONs(biasUp,x) *compressedONs(biasUp,x));
                
                tempT5s(y,x,1) = radialBias(y,x) *(delayedOFFs(y,x) * compressedOFFs(y,x) *compressedOFFs(y,biasRight) - compressedOFFs(y,x) * delayedOFFs(y,biasRight) *compressedOFFs(y,biasRight));
                tempT5s(y,x,2) = radialBias(y,x) *(delayedOFFs(y,x) * compressedOFFs(y,x) *compressedOFFs(y,biasLeft) - compressedOFFs(y,x) * delayedOFFs(y,biasLeft) *compressedOFFs(y,biasLeft));
                tempT5s(y,x,3) = radialBias(y,x) *(delayedOFFs(y,x) * compressedOFFs(y,x) *compressedOFFs(biasDown,x) - compressedOFFs(y,x) * delayedOFFs(biasDown,x) *compressedOFFs(biasDown,x));
                tempT5s(y,x,4) = radialBias(y,x) *(delayedOFFs(y,x) * compressedOFFs(y,x) *compressedOFFs(biasUp,x) - compressedOFFs(y,x) * delayedOFFs(biasUp,x) *compressedOFFs(biasUp,x));
            end
        end % end of pixel-wise operation.
        
        % /*
        % ** Lowpass of T4 and T5 neurons.
        % ** Rightward if motionDir = 1, rightwards; Leftwards if it equals 2; downwards if equalling 3; upwards if 4.
        % */
        for motionDir = 1: 4
            
            T4s(: , : , motionDir) = lowPass(getCertainFrame(tempT4s, motionDir), getCertainFrame(T4s, motionDir), weightDelayT4);
            T5s(: , : , motionDir) = lowPass(getCertainFrame(tempT5s, motionDir), getCertainFrame(T5s, motionDir), weightDelayT5);

            % /*
            % ** Summation of every direction.
            % ** Rightward if motionDir = 1; leftward if it equals 2; upward if equalling 3; downward if 4.
            % */
            motionMatrix(: , : ,  motionDir) = motionSummarise(getCertainFrame(T4s, motionDir), getCertainFrame(T5s, motionDir), ...
                                                       c_ON, c_OFF, exp_ON, exp_OFF, coef_motion, coef_contrast);
        end
           
        % /*
        % ** Local motion directions and magnitude.
        % ** Rightward if motionDir = 1; leftward if it equals 2; upward if equalling 3; downward if 4.
        % */         
        for y = 1: frameHeight
            for x = 1 : frameWidth
            
                lplc2_mag(y, x) = ((motionMatrix(y, x, 1) + motionMatrix(y, x, 2))^2 + (motionMatrix(y, x, 3) + motionMatrix(y, x, 4))^2)^0.5;
                
                if maxMotion < lplc2_mag(y,x)
                    maxMotion = lplc2_mag(y,x);
                end
                
                % /*
                % ** Horizontal motion competetion
                % */
                if motionMatrix(y,x, 1) >= motionMatrix(y,x, 2)
                  
                    horizontalMotion = motionMatrix(y,x, 1);
                
                else
                    
                    horizontalMotion = -motionMatrix(y,x, 2);
                
                end
                
                % /*
                % ** Vertial motion competetion
                % */
                if motionMatrix(y,x, 3) >= motionMatrix(y,x, 4)
                
                    verticalMotion = motionMatrix(y,x, 3);
                    
                else
                    
                    verticalMotion = -motionMatrix(y,x, 4);
                
                end
                
                % /*
                % ** Summation of motion competetion of both. 
                % */
                lplc2_dir(y,x) = atan2(verticalMotion, horizontalMotion) * 180 / pi;
            
                % /*
                % ** Operation for the first quadrant. 
                % */
                if x >= centroidWidth && y >= centroidHeight
                
                    lplc2_region(1) = lplc2_region(1) + activationFunction('GELU_Fast', motionMatrix(y,x, 1) - motionMatrix(y,x, 2));
                    lplc2_region(1) = lplc2_region(1) +  activationFunction('GELU_Fast', motionMatrix(y,x, 4) - motionMatrix(y,x, 3));
                    
                % /*
                % ** Operation for the second quadrant.
                % */   
                elseif x < centroidWidth && y >= centroidHeight
                    
                    lplc2_region(2) = lplc2_region(2) + activationFunction('GELU_Fast', motionMatrix(y,x, 2) - motionMatrix(y,x, 1));
                    lplc2_region(2) = lplc2_region(2) + activationFunction('GELU_Fast', motionMatrix(y,x, 4) - motionMatrix(y,x, 3));
                    
                % /*
                % ** Operation for the third quadrant.
                % */
                elseif x < centroidWidth && y < centroidHeight
                
                    lplc2_region(3) = lplc2_region(3) + activationFunction('GELU_Fast', motionMatrix(y,x, 2) - motionMatrix(y,x, 1));
                    lplc2_region(3) = lplc2_region(3) + activationFunction('GELU_Fast', motionMatrix(y,x, 3) - motionMatrix(y,x, 4));
                    
                % /*
                % ** Operation for the forth quadrant.
                % */
                else 
                    
                    lplc2_region(4) = lplc2_region(4) + activationFunction('GELU_Fast', motionMatrix(y,x, 1) - motionMatrix(y,x, 2));
                    lplc2_region(4) = lplc2_region(4) + activationFunction('GELU_Fast', motionMatrix(y,x, 3) - motionMatrix(y,x, 4));
                   
                    
                end
            
            end % for x = 1: frameWidth
        end % for y = 1: frameHeight
        
        matrixMP(frameCount) = retainPositive(lplc2_region(1)) ...
                                                    * retainPositive(lplc2_region(2)) ...
                                                    * retainPositive(lplc2_region(3)) ...
                                                    * retainPositive(lplc2_region(4)); 
                                                
      
%         matrixMP(frameCount) = activationFunction('Sigmoid', lplc2_region(1), 0.25*frameHeight *frameWidth) ...
%                                                 *activationFunction('Sigmoid', lplc2_region(2), 0.25*frameHeight *frameWidth) ...
%                                                 *activationFunction('Sigmoid', lplc2_region(3), 0.25*frameHeight *frameWidth) ...
%                                                 *activationFunction('Sigmoid', lplc2_region(4), 0.25*frameHeight *frameWidth);                                        
        if matrixMP(frameCount) > 0
            for i = 1:timeLength
                    
                tmpSum = tmpSum + matrixMP(i);
                
            end
            LPLC2_Out(frameCount) = tmpSum/timeLength;
        else
            LPLC2_Out(frameCount) = 0;
        end
        
        for motionDir = 1: 4
                
            matrixCardinal(frameCount, motionDir) = lplc2_region(motionDir);
        
        end
        
    end % for frameCount = 2 : videoLength - 1
    
    modelName = 'lplc2';

%      if switchNoise == 0
%         strength = char(num2str(0));
%         noise_name = 'non';
%      end
% 
%      if switchNoise == 1
%          strength = strcat(num2str(avg), '_' ,num2str(var));
%          noise_name = 'gau';
%      end
% 
%      if switchNoise == 2
%          strength = num2str(density);
%          noise_name = 'snp';
%      end
    
    tempFileName = char(fileName(1:end-4));
    
    combinedName = char(genvarname(strcat(modelName,'_',tempFileName)));
    combinedName = regexprep(combinedName, '0x2D', '_');
    
    matrixToSave1 = strcat(combinedName, '_MP');
    matrixToSave2 = strcat(combinedName,'_Cardinal');
    matrixToSave3 = strcat(combinedName, '_LPLC2OUT');
    
    eval([matrixToSave1, '= matrixMP']);
    eval([matrixToSave2, '= matrixCardinal']);
    eval([matrixToSave3, ' = LPLC2_Out'])
    
    save([combinedName,'.mat'], matrixToSave1, matrixToSave2, matrixToSave3);
    
    
toc   
end