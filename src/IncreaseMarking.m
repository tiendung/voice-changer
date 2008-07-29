function ca = IncreaseMarking(x, p, fs, m)

leftDuration = round( fs / p(1)); 
i = 1 + leftDuration;
len = length(x);
Count = 0;

% for each search regions
% find m pitch mark candidates
ca = [];
LeftThr = 0;
while (i < len)
    rightDuration = round( fs / p(i));
    leftHalf = floor(leftDuration * 0.3);
    rightHalf = floor(rightDuration * 0.3);
    Range = (max(i - leftHalf, LeftThr) : min(i + leftHalf, len));

    Offset = Range(1) - 1;
    c = FindPeakCandidates( x(Range), m , Offset);

    Count = Count + 1;
    ca(Count, :) = c;

    i = c(1); %position of max amplitude in current search region
    leftDuration = round( fs / p(i));
%     LeftThr = c(m + 5);
    i = i + leftDuration;
end
