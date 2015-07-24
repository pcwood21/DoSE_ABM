classdef Client < dsim.Agent

	properties
		destinationServer = -1; % ID of the relay in use
		managementServer = -1; %Server to get relay ID from
		requestFrequency = 1; % 10 Requests/Sec
		nextSendTime=0;
		responseRecv=0;
		responseSent=0;
		endTime=inf;
	end
	
	methods
		function obj=Client()
		end
		
		function execute(obj,time)
			if obj.nextSendTime <= time && time < obj.endTime
				obj.sendRequest();
				obj.responseSent=obj.responseSent+1;
				obj.nextSendTime=time+1/obj.requestFrequency;
				obj.queueAtTime(obj.nextSendTime);
            elseif time < obj.endTime
				obj.queueAtTime(obj.nextSendTime);
			end
           
            while(1)
               msg=obj.recv();
               if isempty(msg)
                    return;
               end
               obj.responseRecv=obj.responseRecv+1;
            end
		end
		
		function ret=getRelayNode(obj)
			ret=-1;
			if( obj.managementServer < 0 && obj.destinationServer < 0 )
				return;
			end
			
			if(obj.managementServer < 0)
				ret=obj.destinationServer;
				return;
			end
			
			if( obj.destinationServer < 0 || ~obj.ping(obj.destinationServer))
				DSim=dsim.DSim.getInstance();
				destAgent = DSim.agentList{obj.managementServer};
                newDest=destAgent.assignRelay(obj.id);
                if newDest > 0
                    obj.destinationServer = newDest;
                end
			end
			
			ret=obj.destinationServer;
		end
		
		function sendRequest(obj)
			if obj.getRelayNode() < 0
				return;
			end
			msg=dsim.msg.ClientRequest();
			msg.setRequestType(1);
            msg.setSenderId(obj.id);
			obj.send(msg,obj.destinationServer);
		end
		
		
	end

end