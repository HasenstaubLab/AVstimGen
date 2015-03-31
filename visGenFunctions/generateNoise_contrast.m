

function moviedata=generateNoise_contrast(maxSpatFreq,maxTempFreq,minTempFreq,contrastSigma,duration, period, framerate)
%%% generates contrast modulated white noise movies
%%% with limited spatial and temporal frequency via inverse fourier transform
%%% written by Cristopher Niell, last modified 10/23/08
%%% typical parameters

%%% TYPICAL VALUES: 
% maxSpatFreq = .05;
% maxTempFreq = 10; % RJM MODIFIED FROM 4Hz
% minTempFreq = 0;
% contrastSigma = .5;    %%% this is the contrast at one-sigma of the pixel distribution
% duration = 1; %(secs) 
% period = 1; %(secs)

rand('state',sum(100*clock))
%tic

%%% stimulus/display parameters

imsize = 60; %% size in pixels 60
% imsize2 = 1600; 

%%imsize = 64;                %% size in pixels 60
%framerate = 60;             %% Hz
imageMag=16;                 %% magnification that movie will be played at 8
screenWidthPix = 1440;        %% Screen width in Pixels  640
screenWidthCm = 40.8;         %% Width in cm  40
screenDistanceCm = 25;      %% Distance in cm
alpha=-1;  %%% exponent in frequency-amplitude power law, 0 gives a flat spectrum
offset=3;   %%% this defines corner frequency in power law

%%% derived parameters
nframes = framerate*duration;
contrast_period = period*framerate;
screenWidthDeg = 2*atan(0.5*screenWidthCm/screenDistanceCm)*180/pi;
degperpix = (screenWidthDeg/screenWidthPix)*imageMag;

%%% frequency intervals for FFT
nyq_pix = 0.5;
nyq_deg=nyq_pix/degperpix;
freqInt_deg = nyq_deg / (0.5*imsize);
freqInt_pix = nyq_pix / (0.5*imsize);
nyq = framerate/2;
tempFreq_int = nyq/(0.5*nframes);

%%% cutoffs in terms of frequency intervals

tempCutoff = round(maxTempFreq/tempFreq_int);
mintempCutoff = round(minTempFreq/tempFreq_int);
maxFreq_pix = maxSpatFreq*degperpix;
spatCutoff = round(maxFreq_pix / freqInt_pix);

%%% generate frequency spectrum (invFFT)
range_mult =1;  %%% this essentially defines the number of non-zero amplitudes, so you don't have to generate the full spectrum
%for noise that extends past cutoff parameter (i.e. if cutoff = 1sigma)
%range_mult=2;
spaceRange = (imsize/2 - range_mult*spatCutoff : imsize/2 + range_mult*spatCutoff)+1;
tempRange =   (nframes /2 - range_mult*tempCutoff : nframes/2 + range_mult*tempCutoff)+1;
[x y z] = meshgrid(-range_mult*spatCutoff:range_mult*spatCutoff,-range_mult*spatCutoff:range_mult*spatCutoff,-range_mult*tempCutoff:range_mult*tempCutoff);

%%% amplitude envelope - drops off as power law
A =single(((x.^2 + y.^2)<=(spatCutoff^2))& ((z.^2)>mintempCutoff)& ((z.^2)<(tempCutoff^2)) ).*(sqrt(x.^2 + y.^2 +offset).^alpha);
%%% can put any other function to describe frequency spectrum in here,
%%% e.g. gaussian spectrum or flat
%%% A = exp(-1*((0.5*x.^2/spatCutoff^2) + (0.5*y.^2/spatCutoff^2) + (0.5*z.^2/tempCutoff^2)));
%%%  A =single(((x.^2 + y.^2)<=(spatCutoff^2))& ((z.^2)<(tempCutoff^2)) );

clear x y z;

%%% generate gaussian noise with given amplitude envelope
invFFT = zeros(imsize,imsize,nframes,'single');
mu = zeros(size(spaceRange,2), size(spaceRange,2), size(tempRange,2));
sig = ones(size(spaceRange,2), size(spaceRange,2), size(tempRange,2));
%%%random phases and amplitudes, or just phases
invFFT(spaceRange, spaceRange, tempRange) = single(A .* normrnd(mu,sig) .* exp(2*pi*i*rand(size(spaceRange,2), size(spaceRange,2), size(tempRange,2))));
%invFFT(spaceRange, spaceRange, tempRange) = single(A .*exp(2*pi*i*rand(size(spaceRange,2), size(spaceRange,2), size(tempRange,2))));
clear use;

%%% in order to get real values for image, need to make spectrum
%%% symmetric
fullspace = -range_mult*spatCutoff:range_mult*spatCutoff; halftemp = 1:range_mult*tempCutoff;
halfspace = 1:range_mult*spatCutoff;
invFFT(imsize/2 + fullspace+1, imsize/2+fullspace+1, nframes/2 + halftemp+1) = ...
    conj(invFFT(imsize/2 - fullspace+1, imsize/2-fullspace+1, nframes/2 - halftemp+1));
invFFT(imsize/2+fullspace+1, imsize/2 + halfspace+1,nframes/2+1) = ...
    conj( invFFT(imsize/2-fullspace+1, imsize/2 - halfspace+1,nframes/2+1));
invFFT(imsize/2+halfspace+1, imsize/2 +1,nframes/2+1) = ...
    conj( invFFT(imsize/2-halfspace+1, imsize/2+1,nframes/2+1));

%%% RJM EDIT
% figure
% imagesc(abs(invFFT(:,:,nframes/2+1)));
% figure
% imagesc(angle(invFFT(:,:,nframes/2)));
%%% END EDIT

%%% invert FFT and scale it to 0-255

%pack
shiftinvFFT = ifftshift(invFFT);
clear invFFT;
imraw = real(ifftn(shiftinvFFT));
clear shiftinvFFT;
immean = mean(imraw(:));
immax = std(imraw(:))/contrastSigma;
immin = -1*immax;
imscaled = (imraw - immin-immean) / (immax - immin);
clear imfiltered;

%%% if contrast modulated, multiply by 0.5*(1-cos)
if contrast_period>0
    for f = 1:nframes
        imscaled(:,:,f) = (imscaled(:,:,f)-.5).*(0.5-0.5*cos(2*pi*f/contrast_period));
    end
    imscaled = imscaled+0.5;
end

moviedata = uint8(floor(imscaled(1:imsize,1:imsize,:)*255)+1);

%%%   to check pixel intensity distribution      (slow!)
%     pixdata = single(moviedata);
%     figure
%     hist(pixdata(:));
%     figure
%

% moviedata_small = moviedata(1:50:,:,:); %RJM

%%% to check that the spectrum is still correct
% %RJM EDIT: 
% clear imscaled
% c = fftn(single(moviedata)-128);
% c = fftshift(c);
% figure
% imagesc(mean(abs(c(:,:,:)),3));
% % END EDIT

% %% to view movie
% for f=1:nframes
%     imshow(moviedata(:,:,f));
%     mov(f) = getframe(gcf);
% end
% toc
%movie(mov,10,30)


