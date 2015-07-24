classdef ClientRequest < dsim.msg.Message

	properties

	end
	
	methods
		function obj=ClientRequest()
            obj.type=1;
            obj.typeName='ClientRequest';
			obj.payload.requestType=0;
			obj.payload.senderId=-1;
		end
	
		function setRequestType(obj,type)
			obj.payload.requestType=type;
		end
		
		function type=getRequestType(obj)
			type=obj.payload.requestType;
		end
		
		function setSenderId(obj,id)
			obj.payload.senderId=id;
		end
		
		function id=getSenderId(obj)
			id=obj.payload.senderId;
		end
	end

end