clear all;
clc;

M=50:50:500;
P=[100 200];
N=1000;


for i=1:length(M)
    for j=1:length(P)
        clientAssign=motag_GreedAsn(N,M(i),P(j));
        clients=1:N;
        atkrs=randsample(clients,M(i));
        relays=1:P(j);
        atkRelays=unique(clientAssign(atkrs));
        survivingClients=clientAssign;
        for k=1:length(atkRelays)
            survivingClients(survivingClients==atkRelays(k))=[];
        end
        numSurvivors=length(survivingClients);
        survivePct(i,j)=numSurvivors/N;
        
    end
end

figure;
hold all;
plot(M,survivePct(:,1))
plot(M,survivePct(:,2))
hold off;
