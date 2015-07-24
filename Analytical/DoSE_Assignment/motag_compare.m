
close all;
clear all;
clc;


nthreats=4;
nClients=2000;
mc=100;

dose.avg_active_relay=zeros(nthreats,mc,1);
dose.eTime=zeros(nthreats,mc,1);
dose.avgPft=zeros(nthreats,mc,1);
dose.nRelays=zeros(nthreats,mc,1);
motag.avg_active_relay=zeros(nthreats,mc,1);
motag.eTime=zeros(nthreats,mc,1);
motag.avgPft=zeros(nthreats,mc,1);
motag.nRelays=zeros(nthreats,mc,1);

for nt=1:nthreats


    for k=1:mc
        y=aSingleThreat(nClients,1,2,nt);
        dose.avg_active_relay(nt,k)=y.avg_active_relay;
        dose.eTime(nt,k)=y.eTime;
        dose.avgPft(nt,k)=y.avgPft;
        dose.nRelays(nt,k)=y.nRelays;
    end
    
    nRelay=mean(dose.avg_active_relay(nt,:));
    for k=1:mc
        y=motag_SingleThreat(nClients,ceil(nRelay/2),nt);
        motag.avg_active_relay(nt,k)=y.avg_active_relay;
        motag.eTime(nt,k)=y.eTime;
        motag.avgPft(nt,k)=y.avgPft;
        motag.nRelays(nt,k)=y.nRelays;
    end
    %keyboard
    nt
end

simTimeScale=max(max([dose.eTime motag.eTime]));
nTxperSec=nClients;

%Compare PFT's
figure;
hold on;
plot(mean(dose.avgPft,2).*mean(dose.eTime,2)/simTimeScale*nTxperSec,'-','linewidth',2,'color','k');
plot(mean(motag.avgPft,2).*mean(motag.eTime,2)/simTimeScale*nTxperSec,'--','linewidth',2,'color','k');
legend('DoSE','MOTAG');
ylabel('Number Failed Transactions per Second (avg)');
xlabel('Number of Insiders');
%ylim([0 0.5]);
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');
hold off;

%Compare PFT's
figure;
hold on;
plot(mean(dose.avgPft,2),'-','linewidth',2,'color','k');
plot(mean(motag.avgPft,2),'--','linewidth',2,'color','k');
legend('DoSE','MOTAG');
ylabel('Avg. Pct. Failed Tx during Attack');
xlabel('Number of Insiders');
ylim([0 0.08]);
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');
hold off;

%Compare Cost's
figure;
hold on;
plot(mean(dose.nRelays,2),'-','linewidth',2,'color','k');
plot(mean(motag.nRelays,2),'--','linewidth',2,'color','k');
legend('DoSE','MOTAG','Location','NorthWest');
ylabel('Number of Unique IP Consumed');
xlabel('Number of Insiders');
%ylim([0 1]);
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');
hold off;

%Compare Time's
figure;
hold on;
plot(mean(dose.eTime,2)*10/60,'-','linewidth',2,'color','k');
plot(mean(motag.eTime,2)*10/60,'--','linewidth',2,'color','k');
legend('DoSE','MOTAG','Location','NorthWest');
ylabel('Time to Find Insiders (min)');
xlabel('Number of Insiders');
%ylim([0 1]);
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');
hold off;
