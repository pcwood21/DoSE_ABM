classdef DSim < handle

	properties
		
		agentList={};
		timedEventQueue;
		currentTime=0;
        endTime=0;
		
	end
	
	methods
	
		function obj=DSim()
			obj.timedEventQueue=java.util.HashMap;
		end
		
		function queueEvent(obj,agentId,time)
			time=max(obj.currentTime,time);
			try
				agentExecList=obj.timedEventQueue.get(time);
			catch %#ok<CTCH>
				agentExecList=[];
			end
			
			if ~isempty(agentExecList)
				agentExecList(end+1)=agentId;
			else
				agentExecList=agentId;
			end

			obj.timedEventQueue.put(time,agentExecList);
		end
		
		function [time,agentExecList]=getNextEvent(obj)
			agentExecList=[];
			time=inf;
			if obj.timedEventQueue.size() < 1
				return;
			end
			time=java.util.Collections.min((obj.timedEventQueue.keySet()));
			agentExecList=unique(obj.timedEventQueue.get(time));
			obj.timedEventQueue.remove(time);
		end
		
		function run(obj,end_time)
			time=0;
            obj.endTime=end_time;
            for k=1:length(obj.agentList)
                agent=obj.agentList{k};
                agent.init();
            end
			while time < end_time
				[time,agentExecList]=obj.getNextEvent();
                obj.currentTime=time;
				for k=1:length(agentExecList)
                    agentId=agentExecList(k);
					agent=obj.agentList{agentId};
                    agent.execute(time);
				end
			end
		end
		
		function send(obj,msg,dest)
			agent=obj.agentList{dest};
            agent.msgQueue{end+1}=msg;
            agent.queueAtTime(obj.currentTime);
		end
		
		function id = addAgent(obj,agent)
			obj.agentList{end+1}=agent;
			agent.id=length(obj.agentList);
			id=agent.id;
		end
		
		
	end
	
	methods (Static)
	
		function obj = getInstance()
			persistent instance;
			if isempty(instance)
				obj=dsim.DSim();
				instance=obj;
			else
				obj=instance;
			end
		end
	end
	
end
