close all; clc; clear all

files = spm_select(1,'.mat','Select cortical thickness file');
load(files);

L = 2*length(label);

CT = zeros(1,L);
CT(1:2:L) = CTV.lh;
CT(2:2:L) = CTV.rh;

k = 1;
for i = 1:L/2
    lab{k} = ['L ',label{i}]; k = k+1;
    lab{k} = ['R ',label{i}]; k = k+1;
end

figure
barh(CT);
set(gca,'Ytick', 1:length(CT),'YtickLabel',1:L);
box off
set(gca,'color','none');
title('CT values, group average');
ylim([1,L])
ylabel('ROI');
xlabel('mm');
set(gcf, 'Position', [500   100   500   1200]);
title('CT')

fCT = zeros(L,size(fCTV.lh,2));

for i = 1:size(fCTV.lh,2)
    fCT(1:2:L,i) = fCTV.lh(:,i);
    fCT(2:2:L,i) = fCTV.rh(:,i);
end

figure,
barh(fCT); box off, set(gca,'color','none');
for i = 1:size(fCTV.lh,2), leg{i} = ['sub ',num2str(i)]; end
legend(leg)
ylabel('ROI')
xlabel('mm')
ylim([1,L])
title('CT, average')
set(gca,'Ytick', 1:length(CT),'YtickLabel',1:L);
set(gcf, 'Position', [500   100   500   1200]);

B = num2cell(1:L);
ROI = (cell2table([B;lab]'));
ROI.Properties.VariableNames{'Var1'} = 'ROI';
ROI.Properties.VariableNames{'Var2'} = 'Label';

disp('Kids  = 1');
disp('Teens = 2');
disp('All   = 3');
in = input ('Enter group type? ');


disp('Age = 1');
disp('EVT = 2');
disp('PPVT = 3');
in2 = input ('covariate type? ');

if in == 1
    if in2 == 1
        load age_kids
        label = 'Age';
        tar = Age;
    end
elseif in == 2
    load age_teens;
    label = 'Age';
    tar = Age;
elseif in == 3
    if in2 == 1
        load age_all
        label = 'Age';
        tar = Age;
    elseif in2 == 2
        load EVT_all,
        load age_all
        label = 'EVT';
        tar = EVT;
    elseif in2 == 3
        load PPVT_all,
        load age_all
        label = 'PPVT';
        tar = PPVT;
    end
end


%% Correlation of CT with targets
for i = 1:size(ROI,1)
    [r,p] = corr(fCT(i,:)',tar,'Type','Spearman');
    rCT(i) = r;
    pCT(i) = p;
end
stat = cell2table(num2cell([rCT;pCT])');
stat.Properties.VariableNames{'Var1'} = 'Corr';
stat.Properties.VariableNames{'Var2'} = 'P';
stat_report = [ROI,stat];
display(stat_report)

figure,
barh(rCT);
set(gca,'Ytick', 1:length(CT),'YtickLabel',1:L);
box off
set(gca,'color','none');
title(['corr ', '(',label,',CT)']);
ylim([1,L])
ylabel('ROI');
xlabel('correlation');
set(gcf, 'Position', [500   100   500   1200]);

idxp = find(pCT < 0.01);

rCT_sig = zeros(1,length(rCT));
rCT_sig(idxp) = rCT(idxp);
hold on
h = barh(rCT_sig);
set(h, 'FaceColor', 'r')
legend('non-sig','sig (p <0.01)')

m = mean(fCT,1)';
[r,p] = corr(m,tar,'Type','Spearman');
figure,
scatter(m,tar);
box off
set(gca,'color','none');
title(['correlation, r = ',num2str(r),' (p =', num2str(p),')']);
ylabel(label);
xlabel('CT')
legend('Subject')

idx_kid = find(Age < 10);
m1 = m;
m1(idx_kid) = NaN;

tar1 = tar;
tar1(idx_kid) = NaN;

hold on
h = scatter(m1,tar1);
legend('kids','teens')
%%



