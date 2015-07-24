
numAttackers1 = 1:1:9; %9
numAttackers2 = 10:10:90; %9
numAttackers3 = 100:100:500; %5
numAttackers=[numAttackers1 numAttackers2 numAttackers3];
numAttackers=logspace(0,2.69897,8); % [1 to 500 logspaced];
numAttackers=ceil(numAttackers); %Remove partials

output=cell(length(numAttackers),1);
parfor i=1:length(numAttackers)
    fprintf('Dispatching Job for %d Attackers\n',numAttackers(i));
    output{i}=sweep_attacker_size(3,numAttackers(i),1000);
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

numClients=1000;

figure;
semilogx(numAttackers,mpft,'-o','linewidth',2,'color','k');
ylabel('Average Pct of Failed Transactions');
xlabel('Number of Attackers');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');

figure
semilogx(numAttackers,mRly,'-o','linewidth',2,'color','k');
ylabel('Average Number of Relays');
xlabel('Number of Attackers');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');

%Single Attacker Plot
figure
plot(output{1}.time,output{1}.pft,'linewidth',2,'color','k');
ylabel('Pct of Failed Transactions');
xlabel('Time (s)');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');
ylim([0 1]);
xlim([0 400]);

%Single Attacker Plot
figure
plot(output{1}.time,output{1}.numRelays,'linewidth',2,'color','k');
ylabel('Number of Relays');
xlabel('Time (s)');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');
ylim([0 20]);
xlim([0 400]);

%Extra Plots
atk100=sweep_attacker_size(3,1,100);
%Single Attacker , 100 clients
figure
plot(atk100.time,atk100.pft,'linewidth',2,'color','k');
ylabel('Pct of Failed Transactions');
xlabel('Time (s)');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');
ylim([0 1]);
xlim([0 400]);

figure
plot(atk100.time,atk100.numRelays,'linewidth',2,'color','k');
ylabel('Number of Relays');
xlabel('Time (s)');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');
ylim([0 20]);
xlim([0 400]);
