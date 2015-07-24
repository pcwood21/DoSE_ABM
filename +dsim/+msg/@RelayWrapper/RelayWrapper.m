classdef RelayWrapper < dsim.msg.Message

	properties
	end
	
	methods
		function obj=RelayWrapper()
            obj.type=3;
            obj.typeName='RelayWrapper';
			obj.payload.msg=[];
			obj.payload.senderId=-1;
			obj.payload.relayId=-1;
		end
		
		function setSenderId(obj,id)
			obj.payload.senderId=id;
		end
		
		function id=getSenderId(obj)
			id=obj.payload.senderId;
		end
		
		function setRelayId(obj,id)
			obj.payload.relayId=id;
		end
		
		function id=getRelayId(obj)
			id=obj.payload.relayId;
		end
		
		function setMsg(obj,id)
			obj.payload.msg=id;
		end
		
		function msg=getMsg(obj)
			msg=obj.payload.msg;
		end
		
	end

end