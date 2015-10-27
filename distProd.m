function stim = distProd(f1,minf,maxf,peak,dur)

sr = 192000;

f2s = exp([log(f1-minf):(log(f1-maxf)-log(f1-minf))/20:log(f1-maxf)]);

nstims = length(f2s);

stim = cell(nstims+1,1);

tone1 = genTone(f1,dur,sr);

for i=1:nstims
	
	tone2 = genTone(f2s(i),dur,sr);
	y = tone1/2+tone2/2;
	stim{i} = y;
	fname = sprintf('distProdStim_F1.%i_F2.%i.mat',f1,f2s(i));
	
	save(fname,'y');
	
end

% put in calc for peak

tone2 = genTone(f1-peak,dur,sr);
y = tone2/2 + tone1/2;
stim{i+1} = y;

%wavwrite(tone2+tone1,3*f1,sprintf('distProdStim_F1.%i_F2.%i.wav',f1,f1-peak));

fname = sprintf('distProdStim_F1.%i_F2.%i.mat',f1,f1-peak);

save(fname,'y');