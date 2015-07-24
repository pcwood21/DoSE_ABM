classdef Server < dsim.Agent
    
    properties
        responseFrequency=2000; %How many replies per second
        nextResponseTime=0;
    end
    
    methods
        
        function obj=Server()
        end
        
        function execute(obj,time)
            if obj.nextResponseTime <= time
                obj.nextResponseTime=time+1/obj.responseFrequency;
                msg=obj.recv();
                if isempty(msg)
                    obj.queueAtTime(obj.nextResponseTime);
                    return;
                end
                obj.respond(msg);
                obj.queueAtTime(obj.nextResponseTime);
            end
        end
        
        function respond(obj,origMsg)
			if isa(origMsg,'dsim.msg.ClientRequest')
				msg=dsim.msg.ServerResponse();
				msg.setServerId(obj.id);
				obj.send(msg,dstid);
            elseif isa(origMsg,'dsim.msg.RelayWrapper')
				rmsg=dsim.msg.ServerResponse();
				rmsg.setServerId(origMsg.getRelayId());
				msg=dsim.msg.RelayWrapper();
				msg.setMsg(rmsg);
				msg.setRelayId(origMsg.getRelayId());
				msg.setSenderId(origMsg.getSenderId());
				obj.send(msg,origMsg.getRelayId());
			end
        end
    end
    
end
