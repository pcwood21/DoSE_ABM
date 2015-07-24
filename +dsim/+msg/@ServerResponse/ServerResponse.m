classdef ServerResponse < dsim.msg.Message

	properties
	end
	
	methods
		function obj=ServerResponse()
            obj.type=2;
            obj.typeName='ServerResponse';
			obj.payload.serverId=0;
		end
		
		function setServerId(obj,id)
			obj.payload.serverId=id;
		end
		
		function id=getServerId(obj)
			id=obj.payload.serverId;
		end
	end

end