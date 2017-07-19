Link = {}
Link_mt = {}

Link_mt.__index = Link

function Link.new()
	local linkObject = {
		xconnector = nil,
		hasEnd = false,
		father = nil,
		conditions = {},
		actions = {},
		params = {},
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
	self.params[name] = value
end

function Link:createConnector()
	local id = ""
	local conditionsTable = {}
	local nConditions = 0
	local nActions = 0
	local conditionParam = false
	local actionParam = false

	for pos, val in pairs(self.conditions) do
		local tempCondition = val.condition
		if conditionsTable[tempCondition] then
			conditionsTable[tempCondition].times = conditionsTable[tempCondition].times+1
		else
			conditionsTable[tempCondition] = {
				times = 1,
			}
			if val.param then
				conditionParam = true
			end
			tempCondition = tempCondition:sub(1,1):upper()..tempCondition:sub(2)
			id = id..tempCondition
			nConditions = nConditions+1
		end
	end

	local actionsTable = {}
	for pos, val in pairs(self.actions) do
		local tempAction = val:getAction()
		if actionsTable[tempAction] then
			actionsTable[tempAction].times = conditionsTable[tempAction].times+1
		else
			actionsTable[tempAction] = {
				times = 1,
			}
			if val:hasParams() then
				actionParam = true
			end
			tempAction = tempAction:sub(1,1):upper()..tempAction:sub(2)
			id = id..tempAction
			nActions = nActions+1
		end
	end

	if tabelaSimbolos.connectors[id] == nil then
		local newConnector = Connector.new(id)
		tabelaSimbolos.connectors[id] = newConnector
		self.xconnector = id
		for pos, val in pairs(self.params) do
			newConnector:addLinkParam(pos, val)
		end
		newConnector:addConditions(conditionsTable)
		newConnector:addActions(actionsTable)
		newConnector:setNConditions(nConditions)
		newConnector:setNActions(nActions)
		newConnector:setConditionParam(conditionParam)
		newConnector:setActionParam(actionParam)
	else
	end
end

function Link:toNCL(indent) --Fazer verificacao aqui
	self:createConnector()

	local link = indent.."<link xconnector=\""..self.xconnector.."\">"
	------ LinkParams 
	for pos, val in pairs(self.params) do
		link = link..indent.."   <linkParam name=\""..pos.."\" value="..val.."/>" 
	end

	------ Conditions
	for __,value  in pairs(self.conditions) do
		link = link..indent.."   <bind role=\"".. value.condition.."\""
		if tabelaSimbolos[value.media] == nil then
			utils.printErro(value.media.." not declared.")
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
--Tables
local conditions = {
	"onSelection","onBeginSelection","onEndSelection",
	"onBeginAttribution","onEndAttribution",
	"onAbortAttribution","onPauseAttribution",
	"onResumeAttribution"
}

local actions = {
	"start","stop","abort","pause","resume","set",
	"startAttribution","stopAttribution",
	"abortAttribution","pauseAttribution","resumeAttribution"
}

local conditionParams = {
	"delay","key","eventType","transition"
}

local actionParams = {
	"delay","eventType","actionType","value","repeat",
	"repeatDelay","duration","by"
}


