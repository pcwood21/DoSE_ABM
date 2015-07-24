classdef MgmtServer < dsim.Agent
    
    properties
        mgmtDB=[];
        targetServer=-1;
        
        avgNumRelays=3;
        relayUpdatePeriod=1;
        nextUpdateTime=0;
        RiskPerRelay=1;
        targetRiskPerRelay=1;
        minRelays=2;
        
        intergral=0;
        lastError=0;
        lastCreateTime=0;
        createDwellTime=2;
        checkNum=0;
        Kpfactor=1;
		
		CRPA=3;
    end
    
    methods
        function obj=MgmtServer(numClients,useTimeRisk)
            obj.mgmtDB=dsim.db.MgmtServerDB();
            obj.mgmtDB.initClientRisk=obj.minRelays/numClients; %Start with Unity, non-zero risk
            obj.mgmtDB.useTimeRisk=useTimeRisk;
        end
        
        function execute(obj,time)
            obj.nextUpdateTime=time+obj.relayUpdatePeriod;
            obj.queueAtTime(obj.nextUpdateTime);
            obj.checkRelays();
            %obj.manageCost();
			obj.RiskPerRelay=obj.targetRiskPerRelay;
            num=obj.manageRelays();
			
        end
        
        function manageCost(obj)
            relayCreationTime=5*2*20;
            Kp=0.0005*obj.relayUpdatePeriod*obj.Kpfactor;
            Ki=2*Kp/relayCreationTime;
            Kd=Kp*relayCreationTime/8;
            Tp=obj.targetRiskPerRelay;
            numRelays=obj.mgmtDB.getNumRelays();
            error=obj.avgNumRelays-numRelays;
            obj.intergral=obj.intergral+error;
            derivative=error-obj.lastError;
            error=error*Kp+obj.intergral*Ki+derivative*Kd;
            obj.RiskPerRelay=Tp-error;
            if obj.RiskPerRelay < 0
                obj.RiskPerRelay=0;
            end
            obj.lastError=error;
        end
        
        function createNewRelay(obj)
            Relay=dsim.RelayNode();
            DSim=dsim.DSim.getInstance();
            obj.lastCreateTime=DSim.currentTime;
            Relay.destinationServer=obj.targetServer;
            DSim.addAgent(Relay);
            Relay.queueAtTime(Relay.startTime);
            obj.mgmtDB.NewRelay(Relay.id);
            %obj.reassignAll();
        end
        
        function removeOneRelay(obj)
            
            Relay=obj.mgmtDB.getMinRiskRelay();
            DSim=dsim.DSim.getInstance();
            %fprintf('Removing at time %d w/ target > %d\n',DSim.currentTime,obj.lastCreateTime+obj.createDwellTime);
            RLA=DSim.agentList{Relay};
            obj.mgmtDB.unassignAllClients(Relay);
            obj.mgmtDB.deleteRelay(Relay);
            RLA.disableNetwork();
            %Ensure at least one relay is accepting new clients
            if obj.mgmtDB.getNumAvailRelays() < 1
                Relay=obj.mgmtDB.getMinClientRelay();
                obj.mgmtDB.clearProtectedRelay(Relay);
            end
        end
        
        function num=manageRelays(obj)
            lastNumRelays=-1;
            numRelays=obj.mgmtDB.getNumRelays();
			num=0;
            while(lastNumRelays ~= numRelays)
                lastNumRelays=numRelays;
                total_risk=obj.mgmtDB.getTotalClientRisk();
                numRelays=obj.mgmtDB.getNumRelays();
                avgRisk=total_risk/numRelays;
                hRisk=total_risk/(numRelays-1);
                if numRelays - 1 <= 0
                    hRisk=inf;
                end
                lRisk=total_risk/(numRelays+1);
                DSim=dsim.DSim.getInstance();
                currentTime=DSim.currentTime;
                if numRelays < obj.minRelays 
                    obj.createNewRelay();
					num=num+1;
                elseif avgRisk > obj.RiskPerRelay && (obj.mgmtDB.getNumUnusedRelay() < obj.mgmtDB.getNumUnassignedClients())
                    obj.createNewRelay();
					num=num+1;
                elseif hRisk < obj.RiskPerRelay && numRelays-1>=obj.minRelays && obj.lastCreateTime + obj.createDwellTime < currentTime
                    obj.removeOneRelay();
					num=num-1;
                end
                numRelays=obj.mgmtDB.getNumRelays();
            end
        end
        
        function assignRisk(obj,relay)
            num_clients=obj.mgmtDB.getNumClients(relay);
            total_risk=obj.mgmtDB.getRiskRelay(relay);
            client_list=obj.mgmtDB.getClientList(relay);
            if num_clients == 1
                %Attacker Found
                DSim=dsim.DSim.getInstance();
                time=DSim.currentTime;
                client=DSim.agentList{client_list(1)};
                if isa(client,'dsim.Attacker')
                    
                %keyboard
                fprintf('Attacker Found: %d at %3.2f\n',client_list(1),time);
                obj.mgmtDB.banClient(client_list(1));
                obj.mgmtDB.removeRiskFromAttacker(client_list(1));
                end
            else
                atkRisk=0;
                attackID=obj.mgmtDB.newAttack();
                for i=1:length(client_list)
                    client_risk=obj.mgmtDB.getClientRisk(client_list(i));
                    %if total_risk > 0
                    %    addedRisk=client_risk/total_risk+obj.CRPA/length(client_list);
                    %else
                        addedRisk=obj.CRPA/length(client_list);
                    %end
                    client_risk=client_risk+addedRisk;
                    atkRisk=atkRisk+client_risk;
                    obj.mgmtDB.setClientRisk(client_list(i),client_risk,addedRisk,attackID);
                end
                obj.mgmtDB.setAttackRiskLimit(attackID,atkRisk);
                %obj.mgmtDB.rebalanceAttacks();
                
            end
            
            
        end
        
        function reassignAll(obj)
             relay_list=obj.mgmtDB.getRelayList();
             for i=1:length(relay_list)
                 relay=relay_list(i);
                 obj.mgmtDB.unassignAvailClients(relay,obj.checkNum);
             end
%              clist=obj.mgmtDB.getRiskSortedClientList();
%              clist=flipdim(clist,1);
%              for i=1:length(clist)
%                  if obj.mgmtDB.isBannedClient(clist(i))
%                      continue;
%                  end
%                  [next_relay,~]=obj.mgmtDB.getMinRiskRelay();
%                  if next_relay > 0
%                      obj.mgmtDB.addClientToRelay(next_relay,clist(i));
%                  end
%                  
%              end
        end
        
        function checkRelays(obj)
            relay_list=obj.mgmtDB.getRelayList();
            obj.checkNum=obj.checkNum+1;
            oneAttacked=0;
            protectRelays=[];
            for i=1:length(relay_list)
                relay=relay_list(i);
                DSim=dsim.DSim.getInstance();
                relayAgent = DSim.agentList{relay};
                if ~relayAgent.canRecvNetwork() && ~relayAgent.firstRun
                    oneAttacked=oneAttacked+1;
                    obj.assignRisk(relay);
                    cl=obj.mgmtDB.getClientList(relay);
                    test=max(cl);
                    DSim=dsim.DSim.getInstance();
                    if ~isa(DSim.agentList{test},'dsim.Attacker')
                        fprintf('Client %d Misclassified\n',max(cl));
                        keyboard
                    end
                    obj.mgmtDB.unassignAllClients(relay);
                    obj.mgmtDB.deleteRelay(relay);
                    %obj.createNewRelay();
                else
                    protectRelays(end+1)=relay;
                end
            end
            
            if oneAttacked >= 1
                %obj.reassignAll();
            end
            num=obj.manageRelays();
			if oneAttacked >= 1
				fprintf('Attack Report: %d Relays Attacked/Deleted, %d Relays Created\n',oneAttacked,num);
			end
            
        end
        
        function relay=assignRelay(obj,client_ID)
            relay=-1;
            if(~obj.mgmtDB.doesClientExist(client_ID))
                obj.mgmtDB.NewClient(client_ID);
                [next_relay,~]=obj.mgmtDB.getMinRiskRelay();
                 if next_relay > 0
                    obj.mgmtDB.addClientToRelay(next_relay,client_ID);
                    relay=next_relay;
                 end
            end
            %Banned Client
            if(obj.mgmtDB.isBannedClient(client_ID))
                relay=-1;
            else %Assign a relay
                 if(obj.mgmtDB.getAssignment(client_ID) > 0)
                     relay=obj.mgmtDB.getAssignment(client_ID);
                elseif(obj.mgmtDB.canAssignNew(obj.checkNum,client_ID)==1)
                    %obj.checkRelays();
                    %Incremental min-risk assignment
                    [next_relay,~]=obj.mgmtDB.getMinRiskRelay();
                    %Similar Risk-Class Assignment
                    %[next_relay]=obj.mgmtDB.getRelaySimilarRisk(client_ID);
                    
                    if next_relay > 0
                        obj.mgmtDB.addClientToRelay(next_relay,client_ID);
                        relay=next_relay;
                    end

                end
            end
        end
        
        
    end
    
end