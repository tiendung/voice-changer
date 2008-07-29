function y = LowBandSpectrumReconstruct(X, Fs, F0, newF0)
% =========================================================================
% Do low-band spectrum reconstruction using method described in below paper
% Ryo Mochizuki, Tetsunori Kobayashi "A Low-band Spectrum Envelope Modeling 
% for High Quality Pitch Modification", ICASSP 2004
% =========================================================================

len = length(X);
amp = abs(X);

%% find the coresponding DFT bins of Fs/2, F0 and newF0
F0Bin = round(len * F0 / Fs) + 1;
HalfFsBin = round(len / 2) + 1;
newF0Bin = round(len * newF0 / Fs) + 1;

%% calculate spectral till alpha as in formula (1)
range = F0Bin : HalfFsBin;              % omega0 < omgegai < pi
meanBin = mean(range);                  % mean omega
meanAmp = mean(amp(range));             % mean spectral amplitude
v1 = log2(range / meanBin);             
v2 = log(amp(range) / meanAmp);
alpha = sum(v1 .* v2) / sum(v1 .^ 2);

%% Ai paramaters in formula (3)
thresh = F0 / newF0;        % thresh = omega0 / omega0'
N = floor(thresh) + 1;      % N in formula (2)
A = zeros(N, 1);
for i = 1 : N 
    if i < thresh
        A(i) = exp( alpha * log2( i / thresh ) ) * amp(F0Bin);
    else
        A(i) = amp(i * newF0Bin);
    end
end

%% W_i(omega) in formula (4)
T0 = round(Fs / F0);
hannWin = hann(T0);
W = zeros(N, len);
maxW = zeros(N, 1);
for i = 1 : N
    range = (0 : T0 - 1)*2*pi*i/T0;
    W(i, :) = abs( fft(hannWin .* cos(range), len));
% subplot(2,1,1); plot(abs(fft(hannWin,2*T0))); subplot(2,1,2); plot(W(i,:)); pause;
% plot(abs(fft(hannWin)));plot(hannWin.*cos(range));
    maxW(i) = max(W(i, : ));
end

%% calculate new spectral amplitude, formula (2)
newAmp = amp;
for k = 1 : floor(newF0Bin*N)
    kw = floor(k*T0/len)+1;
    WO = zeros(N, 1);
    for i = 1 : N
        WO(i) = W(i, kw);
    end
    newAmp(k) = sum(A .* WO ./ maxW);
end

Y = X .* (newAmp ./ amp);
y = real(ifft(Y));

% subplot(2, 1, 1); plot(ifft(X));subplot(2, 1, 2); plot(y); pause;