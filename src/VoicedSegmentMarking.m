function [Marks, Candidates] = VoicedSegmentMarking(x, p, fs)
% =========================================================================
% Find pitch mark candidates in voice segment
% =========================================================================

MaxCandidateNumber = 3;

[MaxAmp, i] = max(x); % find global maximum of amplitudes in voice segment
len = length(x);

% first candidate is maximum amplitude sample in voiced segment
first(1, 1:MaxCandidateNumber + 5) = i;
first(1, 2:MaxCandidateNumber + 1) = 0;

% find marks in right handside
RightCandidates = IncreaseMarking(x(i:len), p(i:len), fs, MaxCandidateNumber);
%find mark in left handside via fliped signal
LeftCandidates = IncreaseMarking(flipud(x(1:i)), flipud(p(1:i)), fs, MaxCandidateNumber);
% combine candidates
Candidates = [flipud((i + 1) - LeftCandidates); first; (i - 1) + RightCandidates ];
Candidates( find(Candidates == i + 1 | Candidates == i - 1) ) = 0; %restore zero guards 

% =========================================================================
% Dynamic programming
% =========================================================================
% init
d = Pitch2Duration(p, fs);

cost = zeros(len, 1);
trace = zeros(len, 1);
len = length(Candidates(:,1));

imin = Candidates(1, MaxCandidateNumber + 2);
imax = Candidates(1, MaxCandidateNumber + 3);
for curr = ListCandidates( Candidates(1, 1 : MaxCandidateNumber)) 
    cost(curr) = log( StateProb(x(curr), x(imin), x(imax)) );
    trace(curr) = 0;
end

% loop
for k = 2 : len
    imin = Candidates(k, MaxCandidateNumber + 2);
    imax = Candidates(k, MaxCandidateNumber + 3);
    for curr = ListCandidates(Candidates(k, 1 : MaxCandidateNumber))
        if trace(curr) ~= 0
            disp('[error] overlap search region');
            break;
        end
        MaxProb = -999999;
        for prev = ListCandidates(Candidates(k - 1, 1 : MaxCandidateNumber)) 
            Prob = log( TransitionProb(prev, curr, d) ) + cost(prev);
            if Prob > MaxProb
                MaxProb = Prob;
                trace(curr) = prev;
            end
        end % prev
        cost(curr) = MaxProb + log( StateProb(x(curr), x(imin), x(imax)) );
    end % curr
end % k

% result
Marks = zeros(1, len);
last = ListCandidates(Candidates(len, 1 : MaxCandidateNumber));
[value, index] = max( cost(last) );
curr = last(index);
prev = trace(curr);
while (prev ~= 0)
    Marks(len) = curr;
    len = len - 1;
    curr = prev;
    prev = trace(curr);
end
Marks(len) = curr;

if len ~= 1 
    disp('[error] do not find all pitch marks');
end

return

% =========================================================================
function sc = StateProb(h, min, max)
% State Probability
    alpha = 1;
%     disp(sprintf('%d %d %d', h, min, max));
    if min == max %the first pitch mark
        sc = 1;
        return;
    end
    sc = ((h - min) / (max - min))^alpha;
return

% =========================================================================
function tc = TransitionProb(i, k, d)
% Transition Probability
    beta = 0.7;
    gamma = 0.6;
    dur = (d(i) + d(k)) / 2; %pitch period
    tc = (1 / (1 - beta * abs(dur - abs(k - i) ) ) )^gamma; 
return

% =========================================================================
function d = Pitch2Duration(p, fs)
%calculate T0
    d = p;
    for i = 1:length(p)
        if p(i)~=0 
            d(i) = fs / p(i);
        end
    end
return

% =========================================================================
function list = ListCandidates(c)
    list = c( find(c));
return
