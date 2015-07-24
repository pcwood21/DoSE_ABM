numRelays=[6 14 17 30 52 76 113 154];
numAttackers=[1 3 6 15 35 85 206 500];
numClients=1000;
dose_pft=[0.0432376237623762 0.122653465346535 0.129752475247525 0.182128712871287 0.233920792079208 0.257524752475248 0.29890099009901 0.326831683168317];

pctBadNet=10;
pctGoodNet=10;
pctPartial=80;

pctAtkInBad=80;
pctAtkInPartial=20;

pft=zeros(10,8);
for l=1:2
for j=1:30
s = RandStream('mcg16807','Seed',j);
RandStream.setDefaultStream(s)

for i=1:length(numAttackers)

    numAttackerBad=0;
    numAttackerPartial=0;
    
for k=1:numAttackers(i)
    val=rand();
    if val < pctAtkInBad/100
        numAttackerBad=numAttackerBad+1;
    else
        numAttackerPartial=numAttackerPartial+1;
    end
end

numRelayBad=1;
numRelayGood=1;
numRelayPartial=1;

for k=1:(numRelays(i)-3)
    val=rand();
    if val<pctBadNet/100
        numRelayBad=numRelayBad+1;
    elseif val < (pctPartial+pctBadNet)/100
        numRelayPartial=numRelayPartial+1;
    else
        numRelayGood=numRelayGood+1;
    end
end

numBadClient=0;
numGoodClient=0;
numPartialClient=0;

for k=1:numClients
    val=rand();
    if val<pctBadNet/100
        numBadClient=numBadClient+1;
    elseif val < (pctPartial+pctBadNet)/100
        numPartialClient=numPartialClient+1;
    else
        numGoodClient=numGoodClient+1;
    end
end


%Random Assignment
badAssigns=randi([1 numRelayBad],1,numAttackerBad);
goodAssigns=randi([1 numRelayBad],1,numBadClient);
rem=[];
for k=1:length(goodAssigns)
    if unique(max(goodAssigns(k)==badAssigns)) == 1
        rem(end+1)=k;
    end
end
goodAssigns(rem)=[];
numBadClientsSaved=length(goodAssigns);

badAssigns=randi([1 numRelayPartial],1,numAttackerPartial);
goodAssigns=randi([1 numRelayPartial],1,numPartialClient);
rem=[];
for k=1:length(goodAssigns)
    if unique(max(goodAssigns(k)==badAssigns)) == 1
        rem(end+1)=k;
    end
end
goodAssigns(rem)=[];

if l==1
numPartialClientsSaved=numPartialClient^2/(numAttackerPartial+numPartialClient);
else
    numPartialClientsSaved=length(goodAssigns);
end


%Assuming that 1 attacker can displace 1 client in the partial region
%numPartialClientsSaved=numPartialClient-numAttackerPartial;
pft(j,i,l)=1-(numBadClientsSaved+numPartialClientsSaved+numGoodClient)/numClients;

end
end
end

figure
semilogx(numAttackers./numClients*100,median(pft(:,:,1),1),'-o','linewidth',2,'color','k');
hold on;
semilogx(numAttackers./numClients*100,median(pft(:,:,2),1),'--o','linewidth',2,'color','k');
semilogx(numAttackers./numClients*100,dose_pft,'-*','linewidth',2,'color','k');
legend('Epiphany+Speak-Up','Epiphany','DoSE');
xlabel('Pct Attackers');
ylabel('Pct of Failed Transactions');
set(findall(gcf,'type','text'),'FontSize',10,'fontWeight','bold');
set(gca,'FontSize',10,'fontWeight','bold');
hold off;

