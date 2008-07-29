function DisplayPitchAndWave(p, x);
% =========================================================================
% Display waveform and pitch contour
% =========================================================================
plot(max(p)/max(x)*x);
hold on;
plot(p, '-r');
hold off;
