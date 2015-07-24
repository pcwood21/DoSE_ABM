function output = motag_SingleThreat(N_clients,Kshuffle,nInsider)

%Small analytical simulation

%N_clients = 1000;
serving=Kshuffle;
Risk=ones(1,N_clients)/1000000;
Clients=1:1:N_clients;
Client_Relay_Asn=zeros(1,N_clients);
bannedClients=[];

%Relay Properties
rNewTime=4; %60 seconds to bring a new relay online
rRecovTime=120; %Time before a relay can be recovered


%DoSE Properties
%RPR=1;
%CRPA=2;
minRelay=Kshuffle+serving;
minDistRelays = 2; %Num of relays that must be online to split clients
progAssignMode = 1; %Do not assign disrupted clients to existing good relays

Relays=1:1:minRelay;
disRelay=zeros(1,length(Relays));
rStartTime=zeros(1,length(Relays));

%Sim Property
endTime=7200;

%Single Attacker
attacker_id=randi([1 N_clients],1,nInsider);

pft=[];
saved_clients=[];
anrly=[];

endsim=0;
nextAtkTime=0;

for time=1:1:endTime

    %Calc Relay Amount
    nRelays = length(Relays(disRelay == 0));
    %Cumulative Risk
    %Target Number of Relays
    tnRelays = Kshuffle+serving;
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
     %Aggression Factor
    vRelays=length(rRisk(rRisk < inf));   
    if vRelays-serving >= 2
        j=1:length(rRisk);
        jmap=j(rRisk<inf);
        jgc=jmap(1:floor(length(jmap)/2));
        k=1;
        %saved_clients=Clients(Client_Relay_Asn ~= 0);
        for i=1:length(saved_clients)
            Client_Relay_Asn(saved_clients(i))=jgc(k);
            k=k+1;
            if k>length(jgc)
                k=1;
            end
        end
        %keyboard
        gClients = Clients;
        gClients(bannedClients)=[];
        aClients = gClients(Client_Relay_Asn(gClients) == 0);
        asn=motag_GreedAsn(length(aClients),nInsider,floor(vRelays/2));
        Client_Relay_Asn(aClients) = asn + 1;
        jbc=jmap(floor(length(jmap)/2)+1:end);
        idxmap=zeros(length(jbc),length(Client_Relay_Asn(aClients)));
        for k=1:length(jbc)
            idxmap(k,:)=(Client_Relay_Asn(aClients)==k+1)*jbc(k);
        end
        
        Client_Relay_Asn(aClients)=max(idxmap,[],1);
        %keyboard
        cr=unique(Client_Relay_Asn);
    for j=cr;
        %fprintf('%d: %d\n',j,length(Client_Relay_Asn(Client_Relay_Asn==j)));
    end
    %fprintf('\n\n');
    end
	
    
    
	%Attack Relay
    atk=0;
    %attacker_id=randi([1 N_clients],1,nInsider);
    if time >= nextAtkTime
        nextAtkTime=randi([1 rNewTime*2],1)+time;
    for k=1:1%length(attacker_id);
        aid=attacker_id(k);
        aid=randi([1 length(attacker_id)]);
        aid=attacker_id(aid);
	ridx=Client_Relay_Asn(aid);
	if ridx > 0 && disRelay(ridx) == 0
        
        %keyboard
		disRelay(ridx)=1;
		nClient= length(Client_Relay_Asn(Client_Relay_Asn == ridx));
		
        if nClient == 1
            bannedClients(end+1)=aid;
            if(length(bannedClients) == nInsider)
                endsim=1;
            end
        else
            %cumRiskTrk(attacker_id,end+1,1:nClient)=
            atk=1;
        end
        Client_Relay_Asn(Client_Relay_Asn == ridx) = 0;
        
    end
    end
    if atk==1
        saved_clients=Clients(Client_Relay_Asn ~= 0);
    else
        saved_clients=[];
    end
    end
    pft(end+1)=1-(length(Client_Relay_Asn(Client_Relay_Asn ~= 0))/length(gClients));
    anrly(end+1)=nRelays;
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