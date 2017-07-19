Connector = {}
Connector_mt = {}

Connector_mt.__index = Connector

function Connector.new(id)
	local connectorObject = {
		id = id,
		conditionParam = false,
		actionParam = false,
		nConditions = 0,
		nActions = 0,
		conditions = {},
		actions = {},
		params = {},
	}
	setmetatable(connectorObject, Connector_mt)
	return connectorObject
end

function Connector:setNConditions (n)
	self.nConditions = n
end
function Connector:setNActions (n)
	self.nActions = n
end
function Connector:setConditionParam (bool)
	self.conditionParam = bool
end
function Connector:setActionParam (bool)
	self.actionParam = bool
end
function Connector:addLinkParam (name)
	self.params[name] = true
end
function Connector:getId() return self.id end

function Connector:addConditions(conditions)
	table.insert(self.conditions, conditions)
end

function Connector:addActions(actions)
	table.insert(self.actions, actions)
end

function Connector:toNCL(indent)
	local connector = indent.."<causalConnector id=\""..self.id.."\">"

	for pos, val in pairs(self.params) do
		connector = connector..indent.."   <connectorParam name=\""..pos.."\" />"
	end
	if self.conditionParam then
		connector = connector..indent.."   <connectorParam name=\"conditionVar\" />"
	end
	if self.actionParam then
		connector = connector..indent.."   <connectorParam name=\"actionVar\" />"
	end
	local conditionString
	local newIndent
	if self.nConditions > 1 then
		conditionString = indent.."   <compoundCondition operator=\"and\">"
		newIndent = indent.."   "
	else
		conditionString = ""
		newIndent = indent
	end
	for __, j in pairs(self.conditions) do
		for pos, val in pairs(j) do
			conditionString = conditionString..newIndent.."   <simpleCondition role=\""..pos.."\""
			if val.times > 1 then
				conditionString  = conditionString.." max=\"unbounded\" qualifier=\"par\""
			end
			conditionString = conditionString.."/>"
		end
	end
	if self.nConditions > 1 then
		conditionString = conditionString..indent.."   </compoundCondition>"
	end
		
	connector = connector..conditionString

	local conditionString
	local newIndent
	if self.nActions > 1 then
		actionString = indent.."   <compoundActions operator=\"seq\">"
		newIndent = indent.."   "
	else
		actionString = ""
		newIndent = indent
	end
	for __, j in pairs(self.actions) do
		for pos, val in pairs(j) do
			actionString = actionString..newIndent.."   <simpleAction role=\""..pos.."\""
			if val.times > 1 then
				actionString  = actionString.." max=\"unbounded\" qualifier=\"par\""
			end
			actionString = actionString.."/>"
		end
	end
	if self.nActions > 1 then
		actionString = actionString..indent.."   </compoundAction>"
	end
		
	connector = connector..actionString


	connector = connector..indent.."</causalConnector>"
	return connector
end
