function s = genTone(cf,d,sr)

%sr = 2.1*cf;

n = sr*d;

s = (1:n)/sr;
s = sin(2*pi*cf*s);
%sound(s,sr);