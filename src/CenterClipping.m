%--------------------------------------------------------------------------
% Center Clipping
%--------------------------------------------------------------------------
function [cc, ClipLevel] = CenterClipping(x, Percentage)

MaxAmplitude = max( abs(x) );
ClipLevel = MaxAmplitude * Percentage;
PositiveSet = find( x > ClipLevel);
NegativeSet = find (x < -ClipLevel);
cc = zeros( size(x) );
cc(PositiveSet) = x(PositiveSet) - ClipLevel;
cc(NegativeSet) = x(NegativeSet) + ClipLevel;
