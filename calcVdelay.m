

function [numflips delay] = calcVdelay(soa, stimOnset, padLen, ifi) 

% calculates flips + scheduled audio delay to allow for 
% SOAs with negative values

% if soa>=0 % this doesn't require visual delay, set both to 0
%     numflips = 0;
%     delay = 0;
% else

if soa >= 0
    soa_s = 0;
else
    soa_s = abs(soa/1e3); % make positive for calculations here
end
v_delay = (stimOnset/1e3) + (padLen/1e3) + soa_s;

numflips = ceil(v_delay/ifi);
m = mod(v_delay,ifi);
delay = ifi - m;

%end