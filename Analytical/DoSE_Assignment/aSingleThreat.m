function output = aSingleThreat(N_clients,RPR,CRPA,nInsider)

%Small analytical simulation

%N_clients = 1000;


Clients=1:1:N_clients;
Client_Relay_Asn=zeros(1,N_clients);
bannedClients=[];

%Relay Properties
rNewTime=4; %60 seconds to bring a new relay online
rRecovTime=120; %Time before a relay can be recovered


%DoSE Properties
%RPR=1;
%CRPA=2;
minRelay=5;
minDistRelays = 2; %Num of relays that must be online to split clients
progAssignMode = 1; %Do not assign disrupted clients to existing good relays

Risk=ones(1,N_clients)/N_clients*minRelay;

Relays=1:1:minRelay;
disRelay=zeros(1,length(Relays));
rStartTime=zeros(1,length(Relays));

%Sim Property
endTime=7200;

%Single Attacker
attacker_id=randi([1 N_clients],1,nInsider);

pft=[];
anrly=[];
endsim=0;
nextAtkTime=0;

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
            aClients = gClients(Client_Relay_Asn(gClients) == 0);
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
        %keyboard
        for i=randperm(length(aClients))
            [val,idx] = min(rRisk);
            %Limit RPR
            %if val > RPR
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
    %attacker_id=randi([1 N_clients],1,nInsider);
    if time >= nextAtkTime
        nextAtkTime=randi([1 rNewTime*2])+time;
    for k=1:1%length(attacker_id);
        aid=attacker_id(k);
        aid=randi([1 length(attacker_id)]);
        aid=attacker_id(aid);
	ridx=Client_Relay_Asn(aid);
	if ridx > 0 && disRelay(ridx) == 0
        %keyboard
		disRelay(ridx)=1;
		nClient= length(Client_Relay_Asn(Client_Relay_Asn == ridx));
		Risk(Client_Relay_Asn == ridx) = Risk(Client_Relay_Asn == ridx) + CRPA/nClient;
        if nClient == 1
            bannedClients(end+1)=aid;
            if(length(bannedClients) == nInsider)
                endsim=1;
            end
        else
            %cumRiskTrk(attacker_id,end+1,1:nClient)=
        end
        Client_Relay_Asn(Client_Relay_Asn == ridx) = 0;
        
    end
    end
    end
    anrly(end+1)=nRelays;
    pft(end+1)=1-(length(Client_Relay_Asn(Client_Relay_Asn ~= 0))/length(gClients));
    if endsim==1
        break;
    end
    
end
%keyboard
output.nRelays=length(Relays);
output.avgPft=mean(pft);
output.eTime=time;
output.nft=sum(pft);
output.avg_active_relay=mean(anrly);

end