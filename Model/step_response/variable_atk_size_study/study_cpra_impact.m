
cpraRange=[1 1.5 2 3 5 10 20 30];

output=cell(length(cpraRange),1);
parfor i=1:length(cpraRange)
    fprintf('Dispatching Job for %d CPRA\n',cpraRange(i));
    output{i}=sweep_attacker_size(cpraRange(i),1,1000);
    fprintf('Done with Job %d\n',i);
end
	
%Plotting
time = output{1}.time;
for i=1:length(output)
    mpft(i)=mean(output{i}.pft);
    mRly(i)=mean(output{i}.numRelays);
    maxRly(i)=max(output{i}.numRelays);
    tpft=output{i}.pft;
    tpft(tpft==0)=[];
    tval=tpft(end);
    ttime=time(tpft==tval);
    atkStopTime(i)=ttime(end);
end

figure;
plot(cpraRange,mpft,'-o','linewidth',2,'color','k');
ylabel('Average Pct of Failed Transactions');
xlabel('CRPA');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');

figure;
plot(cpraRange,mRly,'-o','linewidth',2,'color','k');
ylabel('Average Number of Relays');
xlabel('CRPA');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');

figure;
plot(cpraRange,maxRly,'-o','linewidth',2,'color','k');
ylabel('Max Number of Relays');
xlabel('CRPA');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');

figure;
plot(cpraRange,atkStopTime,'-o','linewidth',2,'color','k');
ylabel('Time to Mitigate Attack');
xlabel('CRPA');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');

figure
hold all
plot(output{8}.time,output{8}.numRelays,'-','linewidth',2);
plot(output{5}.time,output{5}.numRelays,'--','linewidth',2);
plot(output{4}.time,output{4}.numRelays,':','linewidth',2);
plot(output{2}.time,output{2}.numRelays,'-.','linewidth',2);
ylabel('Number of Relays');
xlabel('Time (s)');
set(findall(gcf,'type','text'),'FontSize',12,'fontWeight','bold');
set(gca,'FontSize',12,'fontWeight','bold');
legend('CRPA-30','CRPA-5','CRPA-3','CRPA-1.5');
hold off;
