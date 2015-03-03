% not used???

function [numflips delay] = calcSOAs(soa, ifi) 

% soa is desired soa, negative indicates audio leading 

numflips = floor(soa/ifi); 

m = mod(soa,ifi); 
delay = ifi - m; 