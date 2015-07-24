classdef Attacker < dsim.Client
    
    properties
        targetServer = -1; % ID of the relay to attack
        dwellTime = 1; %Wait time from getting a target to attacking
        nextExecTime=0;
        attackStartTime=0;
        attackInProgress=0;
        attackType = 1; %1 for Layer3/4, 2 for Layer 7
    end
    
    methods
        function obj=Attacker()
        end
        
        %overwrite the init, wait until triggered to attack
        function init(obj)
            obj.queueAtTime(obj.attackStartTime);
        end
        
        function execute(obj,time)
            if obj.attackStartTime == time
                obj.attackInProgress=1;
            end
            
            if obj.attackInProgress && obj.attackType == 2
                obj.sendRequest();
                obj.nextExecTime=time+1/obj.requestFrequency;
                obj.queueAtTime(obj.nextExecTime);
            end
            
            if obj.attackInProgress && obj.attackType == 1
                obj.targetServer = obj.getRelayNode();
                if ( obj.targetServer ) >= 0
                    DSim=dsim.DSim.getInstance();
                    atkAgent = DSim.agentList{obj.targetServer};
                    atkAgent.disableNetwork();
                    atkAgent.attackedBy=obj.id;
                    atkAgent.attackTime=DSim.currentTime;
                end
                obj.nextExecTime=time+1/obj.requestFrequency;
                obj.queueAtTime(obj.nextExecTime);
            end
            
            while(1)
                msg=obj.recv();
                if isempty(msg)
                    return;
                end
                obj.responseRecv=obj.responseRecv+1;
            end
        end
        
        function startAttack(obj,target)
            obj.targetServer = target;
            obj.attackInProgress=1;
            DSim=dsim.DSim.getInstance();
            time=DSim.currentTime;
            obj.queueAtTime(time+obj.dwellTime);
        end
        
        
    end
    
end