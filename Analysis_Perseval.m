close all; clear all
% pathname = 'F:\Cedric\112415-perseval+Tdtomato-7dpi\12415-Slice-1';
% cd('F:\Cedric\112415-perseval+Tdtomato-7dpi\12415-Slice-1')
% 
% fname1 = '112415-Slice1_w1Perceval-1_t1_Projection.tif';
% fname2 = '112415-Slice1_w2Perceval-2_t1_Projection.tif';
% fname3 = '112415-Slice1_w3TxRed_t1_Projection.tif';
% fname4 = 'BW_Mask.tif';

% pathname = 'C:\Users\Simon\Desktop\Cedric_Tracking_Perseval\Data_Set__Migration_Perceval_TdTomato\100915-Slice2';
% cd(pathname)
% 
% fname1 = '100915-Slice2-1-Baseline-perseval1-2-TRITC_w1Perceval-1_t1_Projection.tif';
% fname2 = '100915-Slice2-1-Baseline-perseval1-2-TRITC_w2Perceval-2_t1_Projection.tif';
% fname3 = '100915-Slice2-1-Baseline-perseval1-2-TRITC_w3FITC-TxRed_t1_Projection.tif';
% fname4 = 'BW_Mask.tif';


[fname1,path1] = uigetfile('*_Projection.tif','Open channel 1''s first image');
cd(path1)
[fname2,path2] = uigetfile('*_Projection.tif','Open channel 2''s first image');
cd(path2)
[fname3,path3] = uigetfile('*_Projection.tif','Open channel 3''s first image');
cd(path3)
[fname4,path4] = uigetfile('*BW_Mask.tif','Open channel 3''s first image');
cd(path4)

[fname5,path5] = uigetfile('*Tracks_CellBody_Manual.txt','Open Track');
cd(path5)

[I] = f_openStack(fname1,path1);
[I2] = f_openStack(fname2,path2);
[I3] = f_openStack(fname3,path3);
[BW] = f_openStack(fname4,path4);
Ided = load(fname5);

%%
mcell1 =[];
mcell2 =[];
for i=1:numel(I)
   cell1 = double(BW(i).data) .* double(I(i).data);
   mcell1 = [mcell1  mean(cell1(cell1>0))];
   cell2 = double(BW(i).data) .* double(I2(i).data);
   mcell2 =[mcell2 mean(cell2(cell2>0))];
   
   
   figure(1)
   imshow(cell1,[]);
   figure(2)
   imshow(cell2,[]);

   pause(0.0001)    
end
ratio = mcell2./mcell1;

%%
figure(3)
hold on
plot((1:size(mcell1,2))*0.5,mcell1,'k')
legend()
plot((1:size(mcell2,2))*0.5,mcell2,'b')
legend({'Perceval 1' 'Perceval 2'})
xlabel('time (min)')
ylabel('Persevals') 
saveas(3,'Perceval 1 & 2.pdf','pdf')
figure(4)
plot(ratio,'r')
legend({'Ratio Perceval 2 / Perceval 1'})
xlabel('Frame')
ylabel('Perseval Ratio') 
saveas(4,'ratio 2on1.pdf','pdf')
%%
% Calulate speed
d = [];
for i=1:numel(I)-1
   ided = Ided(Ided(:,3)==i,:);
   ided2 = Ided(Ided(:,3)==i+1,:); 
   dx = (ided2(1)-ided(1))^2;
   dy = (ided2(2)-ided(2))^2;
   di= dx+dy;
   d = [d sqrt(di)];
end

d= (d .* (6.45/60))./ (0.5/60);
save ('Speed.txt', 'd','-double','-ascii')
%%
figure(5)
hold on
plotyy((1:size(ratio,2))*0.5,ratio,(1:size(d,2))*0.5,d)
%
% fastd = d.*(d >=1.5*std(d));
% fastd(fastd == 0) = NaN;
% [hAx,hLine1,hLine2] = plotyy((1:size(ratio,2))*0.5,ratio,(1:size(d,2))*0.5,fastd);
% set(hLine2,'color','r')
% set(hLine2,'marker','o')
% set(hAx(2),'Ylim',[0 400])
% slowd = d.*(d < 1.5*std(d));
% slowd(slowd == 0) = NaN;
% [hAx,hLine1,hLine2] = plotyy((1:size(ratio,2))*0.5,ratio,(1:size(d,2))*0.5,slowd);
% set(hLine2,'color','k')
% set(hAx(2),'Ylim',[0 400])
% %%
% 
% fast = d >= 1.5*std(d);
% slow = d < 1.5*std(d);
% ind = 2*fast + slow
% time = (1:size(ratio,2))*0.5;
% figure(6)
% hold on
% for i=1:size(d,2)-1
%     if ind(i)==1
%         plot([time(i) time(i+1)],[d(i) d(i+1)],'-k')
%     elseif ind(i)==2
%         plot([time(i) time(i+1)],[d(i) d(i+1)],'-r')
%     end
% end
% axis([1 140 0 400])
% %
legend({'Ratio' 'Speed'})
xlabel('Time (min)')
ylabel('Perseval Ratio 2/1') 
saveas(5,'Speed&Ratio)_mig.pdf','pdf')
% hold on

%%
figure(6)
hold on
for i=1:numel(I)-1
   plot(d(i),ratio(i),'o') 
   xlabel('Speed')
   ylabel('Perseval Ratio') 
    
end
saveas(6,'Correlation Speed Ratio.pdf','pdf')


%%  Find migration state
% Speed
figure(7)
hist(d,10)









