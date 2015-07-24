classdef MgmtServerDB < handle

	properties
		relayEntries=[];
		clientEntries=[];
		attackEntries=[];
		nextAttackId=1;
        initClientRisk=0;
        useTimeRisk=0;
        assignPeriod=1;
		rEntryTemplate=struct('ID',-1,'Clients',[],'Protected',0);
		cEntryTemplate=struct('ID',-1,'RelayID',-1,'Risk',0,'startTime',0,'Banned',0,'lastAssign',-1);
		aEntryTemplate=struct('ID',-1,'Clients',[],'Risk',[],'RLimit',0);
	end
	
	methods
		function obj=MgmtServerDB()
			obj.relayEntries=containers.Map('KeyType','uint32','ValueType','any');
			obj.clientEntries=containers.Map('KeyType','uint32','ValueType','any');
			obj.attackEntries=containers.Map('KeyType','uint32','ValueType','any');
		end
		
		function NewRelay(obj,id)
			nRelay=obj.rEntryTemplate;
			nRelay.ID=id;
			obj.relayEntries(id)=nRelay;
		end
		
		function id=newAttack(obj)
			id=obj.nextAttackId;
			obj.nextAttackId=obj.nextAttackId+1;
			nAttack=obj.aEntryTemplate;
			nAttack.ID=id;
			obj.attackEntries(id)=nAttack;
		end
		
		function NewClient(obj,id)
			DSim=dsim.DSim.getInstance();
			time=DSim.currentTime;
			nClient=obj.cEntryTemplate;
			nClient.ID=id;
			nClient.startTime=time;
            nClient.Risk=obj.initClientRisk;
			obj.clientEntries(id)=nClient;
		end
		
		function exists=doesClientExist(obj,client_ID)
			exists=obj.clientEntries.isKey(client_ID);
		end
		
		function exists=doesAttackExist(obj,attack_ID)
			exists=obj.attackEntries.isKey(attack_ID);
		end
		
		function banned=isBannedClient(obj,client_ID)
			Client=obj.clientEntries(client_ID);
			banned=Client.Banned;
		end
		
		function risk=getClientRisk(obj,client_ID)
			Client=obj.clientEntries(client_ID);
            DSim=dsim.DSim.getInstance();
			time=DSim.currentTime;
			timeDiff=time-Client.startTime;
            if obj.useTimeRisk == 1
                risk=Client.Risk+exp(-timeDiff/20);
            else
                risk=Client.Risk;
            end
        end
        
        function clientList=getRiskSortedClientList(obj)
            keys=obj.clientEntries.keys;
            risk=[];
            ids=[];
            for k=1:length(keys)
                Client=obj.clientEntries(keys{k});
                risk(end+1)=obj.getClientRisk(Client.ID);
                ids(end+1)=Client.ID;
            end
            [~,IX] = sort(risk);
            clientList=ids(IX);
        end
		
        function num=getNumUnusedRelay(obj)
            keys=obj.relayEntries.keys;
            num=0;
            for k=1:length(keys)
                Relay=obj.relayEntries(keys{k});
                if isempty(Relay.Clients)
                    num=num+1;
                end
            end
        end
        
        function num=getNumUnassignedClients(obj)
            keys=obj.clientEntries.keys;
            num=0;
            for k=1:length(keys)
                Client=obj.clientEntries(keys{k});
                if Client.RelayID <= 0
                    num=num+1;
                end
            end
        end
        
        function setProtectedRelay(obj,relay_id);
            Relay=obj.relayEntries(relay_id);
            Relay.Protected=1;
            obj.relayEntries(relay_id)=Relay;
        end
        
        function clearProtectedRelay(obj,relay_id)
            Relay=obj.relayEntries(relay_id);
            Relay.Protected=0;
            obj.relayEntries(relay_id)=Relay;
        end
        function setAttackRiskLimit(obj,attack_ID,limit)
            Attack=obj.attackEntries(attack_ID);
            Attack.RLimit=limit;
            obj.attackEntries(attack_ID)=Attack;
        end
        
        function rebalanceAttacks(obj)
            keys=obj.attackEntries.keys;
            for k=1:length(keys)
                Attack=obj.attackEntries(keys{k});
                clients=Attack.Clients;
                indvRisk=zeros(1,length(clients));
                for i=1:length(clients)
                    indvRisk(i)=obj.getClientRisk(clients(i));
                end
                totalRisk=Attack.RLimit;
                weights=indvRisk./totalRisk;
                newRisks=weights.*Attack.Risk;
                newRisks=newRisks.*totalRisk/sum(newRisks);
                diffRisk=newRisks-Attack.Risk;
                %keyboard
                for i=1:length(clients)
                    obj.setClientRisk(clients(i),indvRisk(i)+diffRisk(i),0,-1);
                end
                Attack.Risk=newRisks;
                obj.attackEntries(keys{k})=Attack;
            end
        end
        
		function risk=setClientRisk(obj,client_ID,risk,addedRisk,attack_ID)
			Client=obj.clientEntries(client_ID);
			Client.Risk=risk;
			obj.clientEntries(client_ID)=Client;
			if obj.doesAttackExist(attack_ID)
				Attack=obj.attackEntries(attack_ID);
				Attack.Clients(end+1)=Client.ID;
				Attack.Risk(end+1)=addedRisk;
                obj.attackEntries(attack_ID)=Attack;
			end
		end
		
		function removeRiskFromAttack(obj,attack_ID)
			Attack=obj.attackEntries(attack_ID);
			clients=Attack.Clients;
			risk=Attack.Risk;
			for i=1:length(clients)
				oldRisk=obj.getClientRisk(clients(i));
				newRisk=oldRisk-risk(i);
				obj.setClientRisk(clients(i),newRisk,-1,-1);
            end
            obj.attackEntries.remove(attack_ID);
		end
		
		function removeRiskFromAttacker(obj,attacker_ID)
			keys=obj.attackEntries.keys;
			for k=1:length(keys)
				Attack=obj.attackEntries(keys{k});
				clients=Attack.Clients;
				for i=1:length(clients)
					if clients(i) == attacker_ID
						obj.removeRiskFromAttack(Attack.ID);
					end
				end
			end
		end
		
		function banClient(obj,client_ID)
			Client=obj.clientEntries(client_ID);
			Client.Banned=1;
			obj.clientEntries(client_ID)=Client;
		end
		
		function addClientToRelay(obj,relay_ID,client_ID)
			obj.unassignClient(client_ID);
			Relay=obj.relayEntries(relay_ID);
			Relay.Clients(end+1)=client_ID;
			obj.relayEntries(relay_ID)=Relay;
			Client=obj.clientEntries(client_ID);
			Client.RelayID=relay_ID;
			obj.clientEntries(client_ID)=Client;
		end
		
		function deleteRelay(obj,relay_ID)
			obj.relayEntries.remove(relay_ID);
		end
		
		function rlc=getNumRelays(obj)
			keys=obj.relayEntries.keys;
			rlc=length(keys);
		end
		
		function risk=getTotalRelayRisk(obj)
			keys=obj.relayEntries.keys;
			risk=0;
			for k=1:length(keys)
				risk=risk+obj.getRiskRelay(keys{k});
			end
        end
        
        function risk=getTotalClientRisk(obj)
			keys=obj.clientEntries.keys;
			risk=0;
			for k=1:length(keys)
                if ~obj.isBannedClient(keys{k})
                    risk=risk+obj.getClientRisk(keys{k});
                end
			end
		end
		
		function risk=getRiskClient(obj,client_ID)
			Client=obj.clientEntries(client_ID);
			risk=Client.Risk;
		end
		
		function risk=getRiskRelay(obj,relay_ID)
			Relay=obj.relayEntries(relay_ID);
			risk=0;
			for i=1:length(Relay.Clients)
				risk=risk+obj.getRiskClient(Relay.Clients(i));
			end
		end
		
		function num=getNumClients(obj,relay_ID)
			Relay=obj.relayEntries(relay_ID);
			num=length(Relay.Clients);
		end
		
		function CL=getClientList(obj,relay_ID)
			Relay=obj.relayEntries(relay_ID);
			CL=Relay.Clients;
		end
		
		function RL=getRelayList(obj)
			RL=[];
			keys=obj.relayEntries.keys;
			for k=1:length(keys)
				Relay=obj.relayEntries(keys{k});
				id=Relay.ID;
				if id > 0
					RL(end+1)=id;
				end
			end
        end
		
        function relay_id = getMinClientRelay(obj)
            relay_id=-1;
            minClients=inf;
            keys=obj.relayEntries.keys;
            for k=1:length(keys)
                Relay=obj.relayEntries(keys{k});
                if Relay.ID > 0
                    nClients=obj.getNumClients(Relay.ID);
                    if nClients < minClients
                        minClients=nClients;
                        relay_id=Relay.ID;
                    end
                end
            end
        end
        
        function num = getNumAvailRelays(obj)
            num=0;
            keys=obj.relayEntries.keys;
            for k=1:length(keys)
                Relay=obj.relayEntries(keys{k});
                if Relay.ID > 0
                    if Relay.Protected == 0
                        num=num+1;
                    end
                end
            end
        end
        
		function [relay_id,minRisk]=getMinRiskRelay(obj)
			relay_id=-1;
			minRisk=inf;
			keys=obj.relayEntries.keys;
            nTies=0;
            tiedRelays=[];
			for k=1:length(keys)
				Relay=obj.relayEntries(keys{k});
				if Relay.ID > 0 && Relay.Protected == 0
					risk=obj.getRiskRelay(Relay.ID);
					if risk<minRisk
						minRisk=risk;
						relay_id=Relay.ID;
                        nTies=0;
                        tiedRelays=Relay.ID;
                elseif risk==minRisk
                        nTies=nTies+1;
                        tiedRelays(end+1)=Relay.ID;
                    end
                        
                        
				end
            end
            if nTies > 0
                winner=randi([1 length(tiedRelays)]);
                relay_id=tiedRelays(winner);
            end
        end
        
        function [relay_id] = getRelaySimilarRisk(obj,client_ID)
            relay_id=-1;
			closeRisk=inf;
			keys=obj.relayEntries.keys;
            clientRisk=obj.getClientRisk(client_ID);
            nTies=0;
            tiedRelays=[];
            newRelay=[];
			for k=1:length(keys)
				Relay=obj.relayEntries(keys{k});
				if Relay.ID > 0
					risk=obj.getRiskRelay(Relay.ID);
                    nClients=obj.getNumClients(Relay.ID);
                    avgRisk=risk/nClients;
                    nCR=abs(avgRisk-clientRisk);
  
					if nCR < closeRisk
						closeRisk=nCR;
						relay_id=Relay.ID;
                        nTies=0;
                        tiedRelays=Relay.ID;
                    elseif nCR==closeRisk || nClients == 0
                        nTies=nTies+1;
                        tiedRelays(end+1)=Relay.ID;
                    end
                        
				end
            end
            if nTies > 0
                winner=randi([1 length(tiedRelays)]);
                relay_id=tiedRelays(winner);
            end

        end
		
		function rl=getAssignment(obj,client_ID)
			Client=obj.clientEntries(client_ID);
			rl=Client.RelayID;
		end
		
		function unassignClient(obj,client_ID)
			rl=obj.getAssignment(client_ID);
			if rl>0
			Relay=obj.relayEntries(rl);
			Relay.Clients(Relay.Clients==client_ID)=[];
			obj.relayEntries(rl)=Relay;
			Client=obj.clientEntries(client_ID);
			Client.RelayID=-1;
			obj.clientEntries(client_ID)=Client;
			end
		end
		
		function unassignAllClients(obj,relay_ID)
			Relay=obj.relayEntries(relay_ID);
			clients=Relay.Clients;
			for i=1:length(clients)
				obj.unassignClient(clients(i));
			end
        end
        
        function ret=canAssignNew(obj,checkNum,client_ID)
            Client=obj.clientEntries(client_ID);
            %DSim=dsim.DSim.getInstance();
			%time=DSim.currentTime;
            if checkNum > Client.lastAssign
                Client.lastAssign=checkNum+obj.assignPeriod;
                obj.clientEntries(client_ID)=Client;
                ret=1;
            else
                ret=0;
            end
        end
        
        function unassignAvailClients(obj,relay_ID,checkNum)
			Relay=obj.relayEntries(relay_ID);
			clients=Relay.Clients;
			for i=1:length(clients)
                if obj.canAssignNew(checkNum,clients(i))
                    obj.unassignClient(clients(i));
                end
			end
        end
		
	end

end
