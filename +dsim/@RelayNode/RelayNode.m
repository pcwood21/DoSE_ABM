classdef RelayNode < dsim.Agent
    
    properties
        relayFrequency=2000; %How many forwards per second
        destinationServer=-1;
        nextResponseTime=0;
		startupDelay=5;
        firstRun=1;
        startTime=0;
        attackedBy=-1;
        attackTime=-1;
    end
    
    methods
        
        function obj=RelayNode()
            DSim=dsim.DSim.getInstance();
			time=DSim.currentTime;
            obj.disableNetwork();
            obj.startTime=time+obj.startupDelay;
        end
        
        function init(obj)
			obj.queueAtTime(0);
        end
        
        function execute(obj,time)
            if obj.firstRun==1 && time>=obj.startTime
                obj.enableNetwork();
                obj.firstRun=0;
            elseif obj.firstRun==1
                obj.queueAtTime(obj.startTime)
                return;
            end
            if obj.nextResponseTime <= time
                obj.nextResponseTime=time+1/obj.relayFrequency;
                msg=obj.recv();
                if isempty(msg)
                    return;
                end
                obj.relay(msg);
                
            end
            if obj.hasWaitingMsg()
                obj.queueAtTime(obj.nextResponseTime);
            end
        end
        
        function relay(obj,origMsg)
            if isa(origMsg,'dsim.msg.ClientRequest')
                msg=dsim.msg.RelayWrapper();
                msg.setSenderId(origMsg.getSenderId());
                msg.setRelayId(obj.id);
                msg.setMsg(origMsg);
                obj.send(msg,obj.destinationServer);
            else %Relay response
                obj.send(origMsg.getMsg(),origMsg.getSenderId());
            end
        end
    end
    
end
