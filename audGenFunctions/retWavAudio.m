function y = retWavAudio(ind, dur_dummy, freq_dummy, Fs, playlist)

if ~isempty(strfind(playlist{ind}, '.wav'))
    [y, Fs_aud] = audioread(playlist{ind}); 
elseif ~isempty(strfind(playlist{ind}, '.mat'))
    load(playlist{ind});
end


if size(y,1)<size(y,2)
    y= y'; 
end

if size(y,2)>1
    y = y(:,1); 
end
y = y';




% someday want to check Fs == Fs_aud, and if not, interp/downsample so that
% they're equal 
