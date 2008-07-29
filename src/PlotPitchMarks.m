%--------------------------------------------------------------------------
% Plot pitch marks found by pitch marking algorithm
%--------------------------------------------------------------------------
function PlotPitchMarks(s, ca, pm, p);

% normalization s and d
s=max(p)/max(s)*s;

mark = zeros(size(s));
maxs = max(abs(s));
mark(pm) = maxs;

figure;set(gca,'xlim', [0 length(s)]);
% plot final pith marks
plot(mark,'g');
hold on; 

% plot speech signal
plot(s,':k');  

% plot seach regions
len = length(ca(1,:));
for (i = 1 : length(ca(:,1)) )
    ra = min(ca(i,len-1),ca(i,len)):max(ca(i,len-1),ca(i,len));
    plot(ra,s(ra),'k');
end

%plot T0 contour
plot(p, '-b');

%fist candiates
pm = ca(:, 1);
pm = pm( find(pm) );
plot(pm,s(pm),'*r');

%second candiates
pm = ca(:, 2);
pm = pm( find(pm) );
plot(pm,s(pm),'*m');

%third candiates
pm = ca(:, 3);
pm = pm( find(pm) );
plot(pm,s(pm),'*c');

hold off;
zoom xon;