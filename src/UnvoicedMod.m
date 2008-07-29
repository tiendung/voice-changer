%--------------------------------------------------------------------------
% Time scale modification for unvoice segment
%--------------------------------------------------------------------------
function [output] = UnvoicedMod(input, fs, alpha)
    d = round(0.010 * fs);    

    inputLen = length(input);    
    ta = [];
    for i=1:d:inputLen
        ta = [ta i]; 
    end
    
    outputLen = ceil(alpha * length(input));  
    output = zeros(outputLen, 1);
    ts = [];
    for i=1:d:outputLen
        ts = [ts i]; 
    end
    
    ta_prime = round(ts/alpha);
   
    for i=1:length(ts)-1
        for j=1:length(ta)-1
            if (ta(j) <= ta_prime(i) && ta(j+1) > ta_prime(i))
                output(ts(i):ts(i+1)) = input(ta(j):ta(j+1));
                break;
            end
        end
    end
output = output(ts(1):ts(length(ts)));
return