Link = {}
Link_mt = {}

Link_mt.__index = Link

function Link.new(linha)
	local linkObject = {
		xconnector = nil,
		hasEnd = false,
		father = nil,
		linha = linha,
		conditions = {},
		actions = {},
		linkParams = {},
	}
	setmetatable(linkObject, Link_mt)
	return linkObject
end
--Get
function Link:getType() return "link" end
function Link:getActions() return self.actions end
function Link:getConditions() return self.conditions end
function Link:getEnd() return self.hasEnd end
function Link:getFather() return self.father end

--Set
function Link:setEnd (bool) self.hasEnd = bool end
function Link:setFather (father) self.father = father end
function Link:addCondition(condition)
	table.insert(self.conditions, condition)
end
function Link:addAction(action)
	table.insert(self.actions, action)
end
function Link:addLinkParam (name, value)
	self.linkParams[name] = value
end

function Link:createConnector()
	local id = ""
	local nConditions = 0
	local nActions = 0
	local conditionsTable = {}
	local actionsTable = {}

	for pos, val in pairs(self.conditions) do
		local condition = val.condition
		if conditionsTable[condition] == nil then
			conditionsTable[condition] = 1
			nConditions = nConditions+1
		else
			conditionsTable[condition] = conditionsTable[condition]+1
		end
		condition = condition:sub(1,1):upper()..condition:sub(2)
		if id:find(condition) then
			local __,endCondition = id:find(condition)
			id = id:sub(1, endCondition).."N"..id:sub(endCondition+1)
		else
			id = id..condition
		end
	end

	for pos, val in pairs(self.actions) do
		local action = val.action
		local params = {}
		for i, j in pairs(val.params) do
			params[i] = true
		end
		if actionsTable[action] then
			actionsTable[action].times = actionsTable[action].times+1
		else
			actionsTable[action] = {} 
			actionsTable[action].times = 1
			actionsTable[action].params = params
			nActions = nActions+1
		end
		action = action:sub(1,1):upper()..action:sub(2)
		if id:find(action) then
			local __,endAction = id:find(action)
			id = id:sub(1, endAction).."N"..id:sub(endAction+1)
		else
			id = id..action
		end
	end

	if tabelaSimbolos.connectors[id] == nil then
		print("xconnector: "..id)
		local newConnector = Connector.new(id)
		newConnector:addConditions(conditionsTable)
		newConnector:addActions(actionsTable)
		newConnector:setNActions(nActions)
		newConnector:setNConditions(nConditions)
		tabelaSimbolos.connectors[id] = newConnector
	end
	self.xconnector = id
end

function Link:toNCL(indent) --Fazer verificacao aqui
	if self.hasEnd == false then
		utils.printErro("Link does not have end.", self.linha)
		return ""
	end
	self:createConnector()

	local link = indent.."<link xconnector=\""..self.xconnector.."\">"
	------ LinkParams 
	for pos, val in pairs(self.linkParams) do
		link = link..indent.."   <linkParam name=\""..pos.."\" value="..val.."/>" 
	end

	------ Conditions
	for __,value  in pairs(self.conditions) do
		link = link..indent.."   <bind role=\"".. value.condition.."\""
		if tabelaSimbolos[value.media] == nil then
			utils.printErro("Element "..value.media.." not declared.", self.linha)
		end
		link = link.." component=\""..value.media.."\""
		if value.interface then
			link = link.." interface=\""..value.interface.."\""
		end
		if value.param then
			link = link..">"..indent.."      <bindParam name=\"conditionVar\" value=\""..value.param.."\"/>"
			link = link..indent.."   </bind>"
		else
			link = link.."/>"
		end
	end
	
	------ Actions
	for pos, val in pairs(self.actions) do
		link = link..val:toNCL(indent.."   ")
	end

	link = link..indent.."</link>" 

	return link
end
