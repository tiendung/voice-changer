%--------------------------------------------------------------------------
% Do pitch marking based-on pitch contour using dynamic programming
%--------------------------------------------------------------------------
function pm = PitchMarking(x, p, fs)

global config;
global data;

% split voiced / unvoiced segments
[u, v] = UVSplit(p);

%  pitch marking for voiced segments
pm = [];
ca = [];
first = 1;
waveOut = [];
for i = 1 : length(v(:,1))
    range = (v(i, 1) : v(i, 2));
    in = x(range);
    [marks, cans] = VoicedSegmentMarking(in, p(range), fs);

    pm = [pm  (marks + range(1))];
    ca = [ca;  (cans + range(1))];
    
    ra = first:marks(1)+range(1)-1;
    first = marks(length(marks))+range(1)+1;
    waveOut = [waveOut UnvoicedMod(x(ra), fs, config.timeScale)'];
    waveOut = [waveOut PSOLA(in, fs, marks)];
end

data.waveOut = waveOut;
data.pitchMarks = pm;
data.candidates = ca;

