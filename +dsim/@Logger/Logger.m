classdef Logger < dsim.Agent

	properties
		samplePeriod=1;
		time=[];
		pft=[];
		numRelays=[];
        avgRiskPerRelay=[];
		numAttackers=[];
		
		lastTotalResponse=0;
		lastTotalRequest=0;
        totalRecv=[];
	end
	
	methods
	
		function obj=Logger()
			
		end
		
		function init(obj)
			obj.queueAtTime(0);
		end
		
		function execute(obj,time)
			obj.queueAtTime(time+obj.samplePeriod);
			obj.time(end+1)=time;
			
			mgmtNode=[];
			DSim=dsim.DSim.getInstance();
			for i=1:length(DSim.agentList)
				agent=DSim.agentList{i};
				if isa(agent,'dsim.MgmtServer')
					mgmtNode=agent;
				end
            end
			
			numAtk=0;
			for i=1:length(DSim.agentList)
				agent=DSim.agentList{i};
				if isa(agent,'dsim.Attacker')
					if agent.attackInProgress && agent.destinationServer > 0
						numAtk=numAtk+1;
					end
				end
			end
			
			obj.numAttackers(end+1)=numAtk;

			obj.numRelays(end+1)=mgmtNode.mgmtDB.getNumRelays();
			ttotalRecv=0;
			ttotalReq=0;
            relayIDs=[];
			for i=1:length(DSim.agentList)
				agent=DSim.agentList{i};
				if isa(agent,'dsim.Client') && ~isa(agent,'dsim.Attacker')
					ttotalReq=ttotalReq+agent.responseSent;
					ttotalRecv=ttotalRecv+agent.responseRecv;
                    relayIDs(end+1)=agent.destinationServer;
				end
            end
			
            rlc=length(unique(relayIDs));
            %fprintf('Clients assigned to %d of %d Relays\n',rlc,obj.numRelays(end));
            if (rlc ~= obj.numRelays(end))
               % keyboard;
            end
            %x=unique(relayIDs)
			diffRecv=ttotalRecv-obj.lastTotalResponse;
			obj.lastTotalResponse=ttotalRecv;
			diffReq=ttotalReq-obj.lastTotalRequest;
			obj.lastTotalRequest=ttotalReq;
			
            if diffRecv <= 0 || diffReq <= 0
               obj.pft(end+1)=NaN;
            else
                obj.pft(end+1)=1-diffRecv/diffReq;
            end
            
            obj.totalRecv(end+1)=ttotalRecv;
            
            obj.avgRiskPerRelay(end+1)=mgmtNode.RiskPerRelay;
			
			%Runtime Reporting
			mgmtNode=[];
			for i=1:length(DSim.agentList)
				agent=DSim.agentList{i};
				if isa(agent,'dsim.MgmtServer')
					mgmtNode=agent;
				end
			end
			
			
			%Iterative console output
			
			%fprintf('\n\nSim %2.2f Pct Complete at %d Seconds\n',  DSim.currentTime/DSim.endTime*100,DSim.currentTime);
			%fprintf('\tMgmt Run: %d Relays\n',mgmtNode.mgmtDB.getNumRelays());
			%fprintf('\tTotal Risk: %5.2f \n\tRPR: %5.2f \n\tTarget Relay Count: %5.2f\n',mgmtNode.mgmtDB.getTotalClientRisk(),mgmtNode.RiskPerRelay,mgmtNode.mgmtDB.getTotalClientRisk()/mgmtNode.RiskPerRelay);
			%fprintf('\tCurrent PFT: %4.3f\n',obj.pft(end));
			
		end
		
	end
end