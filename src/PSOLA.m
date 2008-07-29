function [output] = PSOLA(input, fs, anaPm, timeScale, pitchScale)

%% input parameter adjustment
global config;
if exist('timeScale','var') == 0
    timeScale = config.timeScale;
end
if exist('pitchScale','var') == 0
    pitchScale = config.pitchScale;
end
resamplingScale = config.resamplingScale;
reconstruct = config.reconstruct;

%% Calculate input pitch period from analysis pitch marks
len = length(anaPm);
if len <= 3
    output = input';
    return;
end

pitchPeriod = zeros(length(input),1);
for i=2:len
    pitchPeriod(anaPm(i-1):anaPm(i)-1) = anaPm(i)-anaPm(i-1);
end
pitchPeriod(1:anaPm(1)-1) = pitchPeriod(anaPm(1));
pitchPeriod(anaPm(len):length(input)) = pitchPeriod(anaPm(len) - 1);

%% Find synPm of synthetic pitch marks
synPm = []; 
synPm(1) = anaPm(1);
count = 1;
index = synPm(count);

len = length(input);
while index < len
    LHS = 0;
    RHS = 1;

    while (LHS < RHS) && (index < len)
        index = index + 1;
        LHS = timeScale * (index - synPm(count))^2;        
        RHS =  sum(pitchPeriod(synPm(count):index)) / pitchScale;
    end
    
    if LHS > RHS
        count = count + 1;
        synPm(count) = index;
        index = synPm(count) + 1; 
    end
end

%% UnitWaveforms
input = input';
unit = struct('wave', [], 'dft', []);
for i = 2 : length(anaPm) - 1
    left = anaPm(i-1);
    right = anaPm(i+1);
    unit(i).wave  = input(left : right) .* hann(right - left + 1);
    N = length(unit(i).wave);
    M = 2^nextpow2(2*N-1);
%     M = round(1.1*N/pitchScale);
    unit(i).dft = fft(unit(i).wave, M);
end

%% Output signal
outPm = round(synPm * timeScale);
output = zeros(1, outPm(count));

maxLen = 0;
minLen = length(output);

first = 1;
for j=2:length(synPm)-1
    for i=first:length(anaPm) - 2
        if (synPm(j) >= anaPm(i) && synPm(j) < anaPm(i+1)) 

            first = i;
            k = selectCorrectPos(i);
            
            gamma = (synPm(j) - anaPm(k)) / (anaPm(k+1) - anaPm(k));            

            if reconstruct == 1
                F0 = fs / pitchPeriod(anaPm(i));
                newF0 = fs / (outPm(j)-outPm(j-1)); % pitchScale*F0;
                unitWave1 = LowBandSpectrumReconstruct(unit(k).dft, fs, F0, newF0);
                unitWave2 = LowBandSpectrumReconstruct(unit(k+1).dft, fs, F0, newF0);
            else
                unitWave1 = unit(k).wave;
                unitWave2 = unit(k+1).wave;
            end

            newUnitWave = addTogether((1 - gamma)*unitWave1, gamma*unitWave2, 1);
            
            
            if (resamplingScale ~= 1)
                newUnitWave = resampling(newUnitWave, resamplingScale);
            end                    
            
            output = addTogether(output, newUnitWave, outPm(j-1));
            
            if outPm(j-1) < minLen
                minLen = outPm(j-1);
            end
            break;
        end                     
    end
end
% output = output(minLen:maxLen);
output = output(minLen:outPm(count));
    
%% 
    function i = selectCorrectPos(i)
        if i == 1
            i = 2;
        elseif i >= length(anaPm) - 1
            i = length(anaPm) - 2;
        end
    end            
%% 
    function y = addTogether(y, x, t)
        len = length(x);
        max = t + len - 1;
        range = t : max; 

        if max > maxLen
            maxLen = max;
        end

        len = length(y);
        if len < max
            y = [y zeros(1, max - len)];
        end

        y(range) = y(range) + x;
    end

%%
    function y = resampling(x, scale)
        m = length(x);     
        range = 1: scale : m; 
        y = interp1(x, range);
    end
end
