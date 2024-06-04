function [results] = SNR_ERP(ALLEEG,event)

id = {}; base = []; peak = [];

for n=1:length(ALLEEG)
    EEG = ALLEEG(n);
    epochnums = find([EEG.event.type]==event);
    for epochn=1:length(epochnums)
        thisepoch = EEG.data(:,:,epochn);

        % calc SNR as peak(ERP)/std(baseline)
        id{length(id)+1} = EEG.setname(1:7);
        base = [base; std(thisepoch(EEG.times<=0))];
        peak = [peak; EEG.epoch(epochn).noxious_template.magnitudes];
    end
end

results = table(id,base,peak);
results.snr = results.peak./results.base;

end