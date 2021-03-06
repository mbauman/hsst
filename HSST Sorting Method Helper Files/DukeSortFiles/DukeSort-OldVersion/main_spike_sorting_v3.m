%-----------------------------------------------------
%Note: the code could be stable when the spike number is less than about 10000(not exactly),
%basically Tuningparameter1 is set by 10^-5 or 10^-6; but when the spike
%number is huge, you should tune the Tuningparameter1 and Tuningparameter2. 
%-----------------------------------------------------
clear all;close all;
% load TRIAL38_CHAN46_TANKSORT_WAVEFORMS.mat
% for i=1:length(data)
%     Len(i)=size(data{i},2);
% end
load tanksort_waveforms.mat
Channel=5; % choice of channel.
XX =double(tanksort_wf);
% XX =double(data{Channel});
Spike =XX;
% Y=Spike;
%-------------------------------
%---------Alignment--------------------
%%%%%Main change is here%%%%%%%%%%%%%%%%. 
% NegetivePeak=6;% the number of samples =22;
% when the samples of spike is 22, the most waveforms with negetive peak are around 6,  
% aligning waveforms with negetive peak at this point will keep the most information,
% the original function of "alignment_function" align the waveforms which have the negetive peak at the
% point 11 based on the previous data with length 32 by default. 
%%%--------------------------------------
%-------------------------------------------
Maxposition=11;% the number of samples =32; % alignment peak position
[Y,Bmatrix]=alignment_function(Spike,Maxposition);% alignment of spike waveform from plexon software 
%-----------------------------------------
datass_train=Y./mean(max(Y));
datass_test{1}=XX;
%------------------------------------------------------
 burnin =400; num = 200; space = 1; Ncentres=20; K=32;    
 %-----------------------------------------
 % these are emprical value, we will analyze the relationship between noise
 % variance and this parameter.
 TuningParameter1=1*10^4;      
 %----------------------------------
 %--------------------Main program-------- 
spl = Testing_DPBPSVD_Time_depedent_model_v3(datass_train,K,Ncentres,TuningParameter1,burnin,num,space, true);
%-----------------Show result-------------------------
I=find(spl.Likelihood==max(spl.Likelihood));% find the most probablity sample
% I=num;    % taking the last sample 

%% ------------------plot the cluster in the most probablity sample----------
figure(8800);
numgroup=1;
 Neglect_num=1;
   for m=1:numgroup
       datacc{m}=((spl.H_z{I}));
       figure(100);plot((datacc{m}),'r+')
      set(gca,'fontsize',10);
       xlabel('Index of samples','fontsize',10);ylabel('Index of cluster','fontsize',10);
       title(['Channel','-',num2str(m)]);
   end
   
%% ------------------------plot waveforms in each cluster in each subplot-------
 Neglect_num=0.001*size(datacc{1},2);% neglect the cluster with number less 20 (the value depends on the total spike number)
 for mm=1:1
        uniqueIdex=unique(datacc{mm});
        figure(500);
        flag=0;
    for ii=1:length(uniqueIdex);
        idx=find(datacc{mm}==uniqueIdex(ii));
        if length(idx)> Neglect_num 
            flag=flag+1;
            subplot(2,3,flag);hold on;plot(datass_test{mm}(:,idx)),
            set(gca,'fontsize',10);
            xlabel('index of the feature','fontsize',10);ylabel('Amplitude ','fontsize',10);
            title(['Cluster','-',num2str(uniqueIdex(ii))],'fontsize',10);
        end
    end
 end
 
%% ---------------------------plot pca----------------------
for mm=1:1
        dataXX=datass_test{mm};
        dataXX=XX;
        [coeff{mm},score{mm}]=princomp(dataXX.');
        point=[score{mm}(:,1),score{mm}(:,2),score{mm}(:,3)];
        z=datacc{mm};
        Point=[score{mm}(:,1),score{mm}(:,2)];

        figure;
        h = scatterMixture(Point, z);
        set(gca,'fontsize',15);
        xlabel('Pc-1','fontsize',15);
        ylabel('Pc-2','fontsize',15);
       box
end

%% -------plot waveforms in each cluster in one figure --------------
  colors = ['m','b','r','k','c','g','y','w'];
 for tt=1:1
        uniqueIdex=unique(datacc{tt});
        figure(5000+tt)
    for ii=min(uniqueIdex):max(uniqueIdex);
        %format = colors(1+rem(ii,numel(colors)));
        idx=find(datacc{tt}==(ii));
        if length(idx)>Neglect_num
%            hold on;plot(datass_test{tt}(:,idx),format);
           hold on;
           plot(XX(:,idx), 'Color', get(h(ii), 'CData'));
        end
    end
     set(gca,'fontsize',15);
     xlabel('index of the feature','fontsize',15);ylabel('Amplitude ','fontsize',15);
     xlim([1,35]);
     box
 end 
 
 %% -----------------------------------------------------------
 I=find(spl.Likelihood==max(spl.Likelihood));
figure;plot(spl.H_z{I},'r+')
N=length(spl.Likelihood);
for mm=1:N
     z=spl.H_z{mm};
      iidex=find(z==18);
        pp=zeros(2491,1);
        pp(iidex)=1;
        aa(mm)=length(find(pp-label));

end
        idx=find(min(aa)==aa);
        I=idx(1);
        aa(I)
clear dataxx coeff score
     for mm=1:numgroup
        dataxx(:,:,mm)=ec_spikes(mm,:,:);
        dataXX=reshape(dataxx(:,:,mm),size(dataxx,1),size(dataxx,2));
        [coeff{mm},score{mm}]=princomp(dataXX.');
        point=[score{mm}(:,1),score{mm}(:,2)];
        figure;plot(score{mm}(:,1),score{mm}(:,2),'o');
%         z=label+4;
        z=spl.H_z{I};
%          z=result.datacc{3}{mm};
        scatterMixture(point, z);
        iidex=find(z==4);
        pp=zeros(2491,1);
        pp(iidex)=1;
        length(find(pp-label))
     end