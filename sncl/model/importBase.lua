ImportBase = {}
ImportBase_mt = {}

ImportBase_mt.__index = ImportBase

function ImportBase.new()
	local importBaseObject = {
		alias = nil,
		documentURI = nil,
		region = nil,
		baseId = nil
	}
	setmetatable(importBaseObject, ImportBase_mt)
	return importBaseObject
end

--Setters
function ImportBase:setAlias(alias) self.alias = alias end
function ImportBase:setDocumentURI(Uri)
	self.documentURI = Uri
end
function ImportBase.setRegion(region)
	self.region = region
end
function ImportBase.setBaseId(baseId)
	self.baseId = baseId
end

--Getters
function ImportBase.getType()
	return "importBase"
end

--Checagens

-- Gerador de NCL
function ImportBase:toNCL()

	local NCL  = "<importBase documentURI=\""..self.documentURI.."\" alias=\""..self.alias.."\""

	if self.region then
		NCL = NCL.."region=\""..self.region.."\""
	end
	if self.baseId then
		NCL = NCL.." baseId=\""..self.baseId.."/>"
	end

	return NCL
end
