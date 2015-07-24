classdef Agent < handle

	properties
		id=[]; %Unique identifying ID
		isDisabledNetwork=0;
		msgQueue;
    end
    
    methods (Abstract)
        
    end
	
	methods
        
        function execute(obj,time) %#ok<MANU,INUSD>
        end
		
		function disableNetwork(obj)
			obj.isDisabledNetwork=1;
		end
		
		function enableNetwork(obj)
			obj.isDisabledNetwork=0;
		end
		
		function ret = canRecvNetwork(obj)
			ret = ~obj.isDisabledNetwork;
		end
	
		function obj=Agent()
            obj.msgQueue={};
        end
		
		function init(obj)
			obj.queueAtTime(0);
		end
		
		function queueAtTime(obj,time)
			DSim=dsim.DSim.getInstance();
			if time < DSim.currentTime
				time=DSim.currentTime;
			end
			DSim.queueEvent(obj.id,time);
        end
		
		function msg=recv(obj)
			if length(obj.msgQueue) < 1
				msg=[];
				return;
			end
			msg=obj.msgQueue{1};
            obj.msgQueue(1)=[];
        end
        
        function ret=hasWaitingMsg(obj)
            ret = 0;
            if length(obj.msgQueue) > 1
                ret=1;
            end
        end
    end
    
    methods (Static)
        function send(msg,dest)
			DSim=dsim.DSim.getInstance();
			destAgent = DSim.agentList{dest};
			if destAgent.canRecvNetwork()
				DSim.send(msg,dest);
			end
        end
		
		%Returns 1 if dest is reachable
		function ret = ping(dest)
			DSim=dsim.DSim.getInstance();
			destAgent = DSim.agentList{dest};
			if destAgent.canRecvNetwork()
				ret=1;
			else
				ret=0;
			end
		end
    end
end
