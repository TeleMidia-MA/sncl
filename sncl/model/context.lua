Context = {}
Context_mt = {}

Context_mt.__index = Context

function Context.new (id)
	local contextObject = {
		id=id,
		father = nil,
		hasEnd = false,
		sons = {},
		properties={},
	}
	setmetatable(contextObject, Context_mt)
	return contextObject
end

------ Getters ------
function Context:getId() return self.id end
function Context:getType() return "context" end
function Context:getFather() return self.father end
function Context:getEnd() return self.hasEnd end
function Context:getProperties() return self.properties end

------- Setters -------
function Context:setId (id) self.id = id end
function Context:setFather (father) self.father = father end
function Context:setEnd(bool) self.hasEnd = bool end
function Context:addSon (son) table.insert(self.sons, son) end
function Context:addProperty (name, value) 
	self.properties[name] = value
end
function Context:addPort(id, component, interface) end

-- Gerador de NCL
function Context:toNCL(indent)
	local newNCL = indent.."<context id=\""..self.id.."\">"

	for pos,val in pairs(self.properties) do
		newNCL = newNCL..indent.."   <property name=\""..pos.."\" value="..val.."/>"
	end
	for pos,val in pairs(self.sons) do
		newNCL = newNCL..val:toNCL(indent.."   ")
	end

	newNCL = newNCL..indent.."</context>"
	return newNCL
end

