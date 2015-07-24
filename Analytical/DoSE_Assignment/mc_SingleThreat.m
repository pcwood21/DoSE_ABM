function output = aSingleThreat(N_clients,RPR,CRPA)

%Small analytical simulation

%N_clients = 1000;

Risk=ones(1,N_clients)/1000000;
Clients=1:1:N_clients;
Client_Relay_Asn=zeros(1,N_clients);
bannedClients=[];

%Relay Properties
rNewTime=6; %60 seconds to bring a new relay online
rRecovTime=120; %Time before a relay can be recovered


%DoSE Properties
%RPR=1;
%CRPA=2;
minRelay=2;
minDistRelays = 2; %Num of relays that must be online to split clients
progAssignMode = 1; %Do not assign disrupted clients to existing good relays

Relays=1:1:minRelay;
disRelay=zeros(1,length(Relays));
rStartTime=zeros(1,length(Relays));

%Sim Property
endTime=7200;

%Single Attacker
attacker_id=randi([1 N_clients],1);

pft=[];

for time=1:1:endTime

    %Calc Relay Amount
    nRelays = length(Relays(disRelay == 0));
    %Cumulative Risk
    cRisk = sum(Risk);
    %Active Relay Target
    new_nRelays = cRisk/RPR;
    %Target Number of Relays
    tnRelays = max([minRelay,new_nRelays]);
    while tnRelays > nRelays
        Relays(end+1)=length(Relays)+1;
        disRelay(end+1)=0;
        rStartTime(end+1)=time+rNewTime;
        nRelays=nRelays+1;
    end
    
	%Recalc Assignment
	rRisk=zeros(1,length(Relays));
	%Remove attacked relays
    rRisk(disRelay == 1) = inf;
    %Remove non-started relays
    rRisk(rStartTime > time) = inf;
    
    gClients = Clients;
        gClients(bannedClients)=[];
        if progAssignMode == 1
            aClients = gClients(Client_Relay_Asn == 0);
            %Current Risk
            for i=1:length(rRisk)
                rRisk(i)=rRisk(i)+sum(Risk(Client_Relay_Asn==i));
            end
            rRisk(unique(Client_Relay_Asn(Client_Relay_Asn ~= 0)))=inf;
        else
            aClients = gClients;
        end
     %Aggression Factor
    vRelays=length(rRisk(rRisk < inf));   
    if vRelays >= minDistRelays
        
        for i=randperm(length(aClients))
            [val,idx] = min(rRisk);
            %Limit RPR
            %if val > RPR*1.1
            %    continue;
            %end
            idx=idx(1);
            Client_Relay_Asn(aClients(i))=idx;
            rRisk(idx)=val+Risk(i);
        end
    end
	
    cr=unique(Client_Relay_Asn);
    for j=cr;
        %fprintf('%d: %d\n',j,length(Client_Relay_Asn(Client_Relay_Asn==j)));
    end
    %fprintf('\n\n');
    
	%Attack Relay
	ridx=Client_Relay_Asn(attacker_id);
	if ridx > 0 && disRelay(ridx) == 0
        %keyboard
		disRelay(ridx)=1;
		nClient= length(Client_Relay_Asn(Client_Relay_Asn == ridx));
		
        if nClient == 1
            bannedClients(end+1)=attacker_id;
            break;
        else
            %cumRiskTrk(attacker_id,end+1,1:nClient)=
        end
        Risk(Client_Relay_Asn == ridx) = Risk(Client_Relay_Asn == ridx) + CRPA/nClient;
        Client_Relay_Asn(Client_Relay_Asn == ridx) = 0;
    end
    pft(end+1)=1-(length(Client_Relay_Asn(Client_Relay_Asn ~= 0))/length(gClients));
    
end
%keyboard
output.nRelays=length(Relays);
output.avgPft=mean(pft);
output.eTime=time;
output.nft=sum(pft);

end