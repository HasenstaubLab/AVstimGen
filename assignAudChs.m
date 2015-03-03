function audio_allChs = assignAudChs(nr_channels, chSelect, audCh, audTrCh, trTrCh, liTrCh)  

audio_allChs = zeros(nr_channels, length(audCh)); 

for i = 1:nr_channels    
    switch chSelect{i}
        case 'Audio'
            audio_allChs(i,:) = audCh;
        case 'Audio Trig'
            audio_allChs(i,:) = audTrCh;
        case 'Trial Trig'
            audio_allChs(i,:) = trTrCh;
        case 'Light Trig'
            audio_allChs(i,:) = liTrCh;      
        case 'All Trigs One Ch' 
            audio_allChs(i,:) = trTrCh;    
        case 'Empty'
    
    end
end



        