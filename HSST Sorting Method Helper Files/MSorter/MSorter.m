clear
close all
clc
addpath D:\data\K11_5L\sectioned_lag\  % input folder
addpath D:\data\K11_5L\detected_lag\ % destination folder
addpath D:\M-Sorter\M_sorting\  % sorting program


%% set parameters
% S scales: 1st S for template generation, 2nd S for detection
Svalue = [7,3]; 
% template number
tempclass = 6; 
% tau
Thr = [-4e-5 -3e-5]; % detection threshold (V)
mode = 'neg'; % threshold type, 'neg' for negative spikes, 'pos' for positive spikes, 'both' for both kinds

% supplementary parameters
Fr = 24.414; % sampling frequency (kHz)
BandPass_Hi = 300; % bandpass filter, high pass band (Hz)
BandPass_Lo = 3000; % bandpass filter, low pass band (Hz)
Thr_min = 4e-5; % Minimum peak-to-peak value (V)
Thr_max = 1.5e-4; % Maximum peak value (V)
corr_sig = 0.75; % Correlation coefficient significance level
dist_sig = 4e-8; % Distance to the template (V square)
dur = 36; % Duration of templates
W = 3200; % Window length

% create two folders: one to save the original waveforms, the other to save
% the results after sorting
% original waveform folder
filename='D:\data\K11_5L\sectioned_lag\';

% result folder
destname='D:\data\K11_5L\detected_lag\';
fid = fopen('D:\data\K11_5L\detected_lag\summary.txt','wt');

% This program will extract all the files in the waveform folder, and save
% the names in variable 'dataname'
D=dir(filename);
m=length(D);
dataname =cell(1,m-2);
for t=3:m
    dataname(t-2)= {strcat(D(t,1).name)} ;
end

%% M-Sorter
for i=3:t
        disp('-------------------------------');
        str = strcat(char(dataname(i)))
        disp('Loadind data...');
        S = load(str);
        names = fieldnames(S);
        eval(['data=S.',names{1},';' ]);
        clear S
        % data scaling (if needed)
        data = double(data)/32767000;
        [b,a]=ellip(2,0.1,40,[BandPass_Hi BandPass_Lo]*2/(Fr*1000));
        Signal=filtfilt(b,a,data);
        t_marker = 0;
    for S1=1:2
        tic
        if S1==1
            L = Svalue(S1);
            [spikes index Rate_ASU duration] =MSorter_detection (Signal(1:min(Fr*1000*60,length(Signal))),L,Fr,mode,Thr(S1),dur,W);
            datanametemp = dataname{i};
            desstr = strcat(destname,datanametemp(1:length(datanametemp)-4),'_S_',num2str(L),'.mat');
            disp('Template Generating...');
            save(desstr, 'index', 'spikes');
            str_temp=strcat('S=',num2str(L));
            str_rate=strcat('Rate=',num2str(Rate_ASU));
            fprintf(fid,'%s\t %s\t %s\n',char(dataname(i)),str_temp,str_rate);
            fname = strcat(destname,datanametemp(1:length(datanametemp)-4));
            if size(spikes,1)>10
                template = MSorter_template_generation(fname,Fr,spikes,tempclass,Thr_max);
                t_marker = 1;
            else
                disp('poor recording quality: no qualified spikes')
                t_marker = 0;
            end
        elseif t_marker == 1
            L = Svalue(S1);
            disp('Detecting...');
            [spikes index Rate_ASU duration] =MSorter_detection (Signal,L,Fr,mode,Thr(S1),dur,W);
            datanametemp = dataname{i};
            desstr = strcat(destname,datanametemp(1:length(datanametemp)-4),'_S_',num2str(L),'.mat');
            save(desstr, 'index', 'spikes');
            str_temp=strcat('S=',num2str(L));
            str_rate=strcat('Rate=',num2str(Rate_ASU));
            fprintf(fid,'%s\t %s\t %s\n',char(dataname(i)),str_temp,str_rate);
            disp('Clustering...');
            fname = strcat(destname,datanametemp(1:length(datanametemp)-4),'_S_',num2str(L),'_templatesort');
            MSorter_template_matching(fname,template,Fr,spikes,index,duration,Thr_min,dist_sig,corr_sig);
            disp('Done!');
        end
        toc
        
    end
end
    
close all
fclose(fid)
disp('done')