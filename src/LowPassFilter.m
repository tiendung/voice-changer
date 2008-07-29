function [y, N] = LowPassFilter( x, Fs, Fc)

if Fc == 0
    y = x;
    N = 0;
    return;
end

N = 0;
bb=exp(-1/(Fs/Fc));
y=filter(1-bb,[1 -bb],x);
