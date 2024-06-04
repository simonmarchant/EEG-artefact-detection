function artitable = add_multiple_features(artitable)
% eg. outputtable = add_multiple_features(balancedgrouped);
% once you've done this, you can save the table to file using 
% writetable(outputtable, 'balanced_epochs.csv')

displayplots = true;
Fs = 2000;
ids_missing_data = [];
spectra = nan([height(artitable),106]);
warning('off','MATLAB:colon:nonIntegerIndex')
warning('off','MATLAB:table:RowsAddedNewVars')
for n=1:height(artitable)
    name=artitable{n,'ID'};

    % load epoched files in folder at spath
    spath = strcat('data','/',name,'/');
    file_name = dir(strcat(spath,'*_epocheddata.mat'));
    load(strcat(spath,file_name(1).name)) % load first file

    % find epoch & check exists & correct length
    annot=string(artitable.UrType(n));
    epochn = find(strcmp(annotations_sel,annot),1);
    if ~epochn
        ids_missing_data=[ids_missing_data;name];
        continue
    end
    errmsg = '%s is %.1d in %s';
    assert(epochlengthpre==0.5,sprintf(errmsg,'epochlengthpre',epochlengthpre,name))
    assert(epochlengthpost==1,sprintf(errmsg,'epochlengthpost',epochlengthpost,name))
    
    % time domain features
    eeg = data_epochs_EEG(1,:,epochn);
    artitable.Variance(n) = var(eeg);
    artitable.LogVariance(n) = log(artitable.Variance(n));
    artitable.Skew(n) = abslocalskew(eeg, Fs);
    artitable.Kurtosis(n) = kurtosis(eeg);
    [~, temp] = deltaV(eeg, 100, Fs*0.05);
    artitable.DeltaV(n) = temp;
    [~, temp] = deltaV(eeg, 100, Fs*1.5);
    artitable.DeltaV1(n) = temp;
    artitable.DeltaVschmidt(n) = deltaV(eeg, 800, Fs*10);
    artitable.DeltaVslater(n) = deltaV(eeg, 100, Fs*0.05);
    artitable.SumDv50(n) = abs(sumderivatives(eeg, Fs*0.05));
    artitable.SumDv100(n) = abs(sumderivatives(eeg, Fs*0.1));
    artitable.SumDv200(n) = abs(sumderivatives(eeg, Fs*0.2));
    artitable.SumDv300(n) = abs(sumderivatives(eeg, Fs*0.3));
    artitable.SumDv500(n) = abs(sumderivatives(eeg, Fs*0.5));
    artitable.HiguchiFD(n) = hfd(eeg, floor(length(eeg)/2));
    artitable.KatzFD(n) = katz(eeg, floor(length(eeg)/2));
    [~, temp] = haart(eeg(1:end-1), 6);
    artitable.Wavelet1(n) = kurtosis(temp{1});
    artitable.Wavelet2(n) = kurtosis(temp{2});
    artitable.Wavelet3(n) = kurtosis(temp{3});
    artitable.Wavelet4(n) = kurtosis(temp{4});
    artitable.Wavelet5(n) = kurtosis(temp{5});
    artitable.Wavelet6(n) = kurtosis(temp{6});
    artitable.RmsAmplitude(n) =  rms(eeg-mean(eeg));

    % frequency domain features
    artitable.LogHalfHzPwr(n) = -log(baseline_drift(eeg,Fs,0.5));
    [artitable.Lambda(n),artitable.Fiterror(n),artitable.MaxSpecDev(n)] = spectrum_fit(eeg, Fs, 2, 70);
    bands = [0.2,3.5;4,7.5;8,13;14,30;30,70]; %doi.org/10.1177/1094428118804657
    bandnames = {'Delta','Theta','Alpha','Beta','Gamma'};
    for m=1:5
        highpass = bands(m,1);
        lowpass = bands(m,2);
        bandname = bandnames(m);
        [lambda,fiterror] = spectrum_fit(eeg, Fs, highpass, lowpass);
        artitable{n,strcat(bandname,'Lambda')} = lambda;
        artitable{n,strcat(bandname,'Fiterror')} = fiterror;
        psdx = powerspectraldensity(eeg, Fs, highpass, lowpass);
        artitable{n,strcat(bandname,'LogPower')} = log(mean(psdx));
    end

    % display plots for comparison
    if displayplots
        f1=figure; 
        time = [-epochlengthpre:1/Fs:epochlengthpost];
        baselined_EEG = data_epochs_EEG(1,:,epochn) - mean(data_epochs_EEG(1,:,epochn));
        plot(time,baselined_EEG)
        ylim([-150,150])
        set(gca,'ydir','reverse')
        ylabel('EEG amplitude (uV)')
        xlabel('Time from stimulus (sec)')
        pseudo = artitable.Pseudo(n);
        title(strcat(num2str(pseudo,'%03.0f'),'___',annot,'___',name,' epoch# ',num2str(epochn)), 'Interpreter','none')
        w = waitforbuttonpress;
        close(f1)
    end
end
warning('on','MATLAB:colon:nonIntegerIndex')
warning('off','MATLAB:table:RowsAddedNewVars')

if ids_missing_data
    error('There is missing data: %s', ids_missing_data)
end
end