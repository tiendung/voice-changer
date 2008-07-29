function PeakCandidates = FindPeakCandidates( x, MaxCandidateNumber, Offset )

%% init
len = length(x);
x1 = circshift(x, [1 1]);
x2 = circshift(x, [-1 -1]);
PeakIndices = find(x >= x1 & x >= x2); %find peaks
% PeakIndices = PeakIndices( find(PeakIndices ~= 1 & PeakIndices ~= len)); % remove two bound peak candidates
[y, SortedIndices] = sort( x(PeakIndices), 'descend');  %sort peaks in descending amplitude

MinDur = round(len / 7);
l = length(SortedIndices);
i = 1;
%% iterative select and remove
while (i < l)
    j = i + 1;
    % remove peaks located in MinDur range of current selected peak
    while (j <= l)
        if abs(PeakIndices(SortedIndices(i)) - PeakIndices(SortedIndices(j))) < MinDur
            SortedIndices(j) = [];
            l = l - 1;
        else
            j = j + 1;
        end
    end
    i = i + 1;
end

%% basic information
PeakCandidates = zeros(1, MaxCandidateNumber);
range = 1 : min( MaxCandidateNumber, length(SortedIndices) );
PeakCandidates( range ) = PeakIndices( SortedIndices(range) ) + Offset;

%% added information
[y, imin] = min(x);
[y, imax] = max(x);
PeakCandidates(1, MaxCandidateNumber + (1:5)) = [- Offset; imin; imax; 1; len] + Offset;

