%--------------------------------------------------------------------------
% detect pitch value of a frame using autocorrelation method
%--------------------------------------------------------------------------
function pitch = PitchDetection(x, fs)
% Detect pitch in a speech segment
% pitch = 0 for unvoiced segment

MinLag = round( fs / 500);
MaxLag = round( fs / 70);

cc = CenterClipping(x, 0.3); 								% Center Cliping for pre-processing
AutoCorr = xcorr(cc, MaxLag, 'coeff'); 			% normalized ACF (AutoCorrelation Function)
AutoCorr = AutoCorr(MaxLag + 1 : 2*MaxLag); %take half of ACF


[MaxValue, MaxIndex] = max(AutoCorr(MinLag : MaxLag)); %search max value of ACF in search region
MaxIndex = MaxIndex + MinLag - 1;

HalfIndex = round(MaxIndex/2);
HalfValue = AutoCorr(HalfIndex);

[MinValue, MinIndex] = min(AutoCorr(1 : MaxIndex));

MeanValue = mean(AutoCorr);

if MaxValue > 0.35 && MinValue < 0 && IsPeak(MaxIndex, MinLag, MaxLag, AutoCorr)
    pitch = fs / (MaxIndex);
    else pitch = 0;
end

% DisplayInfor;

    function v = IsPeak(i, min, max, x)
        v = false;
        if i == min || i == max
            return
        end
        if x(i) < x(i-1) || x(i) < x(i+1)
            return
        end
        v = true;
    end

    function DisplayInfor
    % =========================================================================
    %Display information for voice/unvoice decision for each segment
    % =========================================================================
        subplot(2,1,1);plot(x);
        subplot(2,1,2);plot(AutoCorr);
        hold on; 
        plot(MaxIndex,MaxValue,'ok');
        plot(MinIndex,MinValue,'xr');
        plot(HalfIndex,HalfValue,'+m');
        plot(1:MaxLag,MeanValue);
        disp(sprintf('MAX[%3d %2.4f] MIN[%3d %2.4f]',MaxIndex, MaxValue, MinIndex, MinValue));
        pause;
        hold off;
        disp(sprintf('Pitch=%d MinLag=%d MaxLag=%d MaxIndex=%d MaxAC=%2.8f MinAC=%2.8f',pitch, MinLag,MaxLag,MaxIndex,MaxValue, MinValue));
    end
end
