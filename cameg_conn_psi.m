function cameg_conn_psi(Value)
% ___________________________________________________________________________
% Connectivity analysis of MEG data (CA-MEG)
%
% Copyright 2016 Cincinnati Children's Hospital Medical Center
% Reference
%
%
% v1.0 Vahab Youssofzadeh 21/07/2016
% email: Vahab.Youssofzadeh@cchmc.org
% ___________________________________________________________________________
disp('Connectivity measure, PSI ...')

load cameg_datafile
% load(files)

%% Connectivity analysis
cfg.method = 'psi';
% parameters for PSI-calculation
% fs = 1200;
% fs = input('Enter sampling frequency e.g. 1200 [Hz]: ');
epleng = [];



%% PSD
% figure,
% y = spectopo(Value, length(Value), fs, 'limits' ,[1 40 NaN NaN -10 10],'plot', 'on');
% title('Spectral components of input data');
% clickableLegend(gca,roi, 'plotOptions', {'MarkerSize', 6});
% set(gcf, 'Position', [800   100   800   700]);

% fq = input('Enter frequency range [1,30]: ');

% freqs = fq(1):fq(2);
% freqs*legth()
freqs{1} = 2:4;
freqs{2} = 4:7;
freqs{3} = 8:12;
freqs{4} = 15:29;
freqs{5} = 1:29;

label = {'Delta','Theta','Alpha','Beta','All freq'};
% [psi, stdpsi, psisum, stdpsisum]=data2psi(Value',segleng,epleng,freqs);
seglen = length(Value);

figure,
for i=1:length(freqs)
    [psi, stdpsi, ~, ~] = data2psi(Value',seglen,epleng,freqs{i});
    npsi = abs(psi./(stdpsi+eps));
    edge{i} = npsi;
    subplot(3,2,i)
    h{i}  = plot_conn(edge{i},table2array(A(:,1)), 'nPSI'); title(label{i});
    set(gcf, 'Position', [800   100   800   700]);
end
n = length(psi);


% note, psi, as calculated by data2psi corresponds to \hat{\PSI}
% in the paper, i.e., it is not normalized. The final is
% the normalized version given by:

% for i = 1:n
%     roi{i}= Atlas.Scouts(i).Region;
%     roi_l{i}= Atlas.Scouts(i).Label;
% end

% figure,
% hl = plot(Time, Value);
% xlabel('Time(s)');
% ylabel('Amplitude(AU)');
% title('source activities');
% clickableLegend(hl,roi, 'plotOptions', {'MarkerSize', 6});
% set(gcf, 'Position', [800   100   1200   800]);

display('1: Delta');
display('2: Theta');
display('3: Alpha');
display('4: Beta');
display('5: full freq');
in  = input('Band selection (1-5):');
edge = edge{in};
figure,
plot_conn(edge,table2array(A(:,2)), 'nPSI'); title(label{in});
set(gcf, 'Position', [800   200   1000   1000]);

% plot_conn(npsi,roi, 'npsi');
% save cameg_npsi npsi psi

in = input('Thresholding (yes = 1)?');

if in ==1
    thre = input('Set the threshold: ');
    edge = edge > thre;
    plot_conn(edge,roi, 'thresholded npsi');
    set(gcf, 'Position', [800   200   1000   1000]);
end
dlmwrite('edge.edge',edge,'\t');
save cameg_matfile edge roi

disp('(thresholded or org) connectivity matrix was saved!')

% Power of conn
cp = con2power(edge);
figure, barh(cp),
set(gca,'ytick', 1:length(cp),'ytickLabel',roi);
box off
set(gca,'color','none');
title('Connectivity Strength');
set(gcf, 'Position', [900   200   500   900]);

%% Updating furface file
cameg_datapre_updatesurf(cp)



