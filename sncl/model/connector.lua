Connector = {}
Connector_mt = {}

Connector_mt.__index = Connector

function Connector.new(id)
	local connectorObject = {
		id = id,
		nConditions = 0,
		nActions = 0,
		linkParams = {},
		conditions = {},
		actions = {},
	}
	setmetatable(connectorObject, Connector_mt)
	return connectorObject
end

function Connector:getId() return self.id end

function Connector:setNConditions (n)
	self.nConditions = n
end
function Connector:setNActions (n)
	self.nActions = n
end
function Connector:addLinkParam (param)
	--TO-DO
end
function Connector:addConditions (conditions)
	self.conditions = conditions
end
function Connector:addActions (actions)
	self.actions = actions
end

function Connector:toNCL (indent)
	local connector = indent.."<causalConnector id=\""..self.id.."\">"

	-- Conditions
	local conditionsString = ""
	if self.nConditions > 1 then
		conditionsString = indent.."   <compoundCondition operator=\"and\">"
		newIndent = indent.."   "
	else
		conditionsString = ""
		newIndent = indent
	end
	for pos, val in pairs(self.conditions) do
		conditionsString = conditionsString..newIndent.."   <simpleCondition role=\""..pos.."\" />"
	end
	if self.nConditions > 1 then
		conditionString = conditionString..indent.."   </compoundCondition>"
	end

	-- Actions
	local actionsString = ""
	if self.nActions > 1 then
		actionsString = indent.."   <compoundAction operator=\"seq\">"
		newIndent = indent.."   "
	else
		actionsString = ""
		newIndent = indent
	end
	for pos, val in pairs(self.actions) do
		for i, j in pairs(val.params) do
			connector = connector..newIndent.."   <connectorParam name=\""..i.."\"/>"
		end
		actionsString = actionsString..newIndent.."   <simpleAction role=\""..pos.."\""
		if val.times > 1 then
				actionsString  = actionsString.." max=\"unbounded\" qualifier=\"par\""
		end
		for i, j in pairs(val.params) do
			actionsString = actionsString.." "..i.." = \"$"..i.."\""
		end
		actionsString = actionsString.." />"
	end
	if self.nActions > 1 then
		actionsString = actionsString..indent.."   </compoundAction>"
	end

	connector = connector..conditionsString
	connector = connector..actionsString
	connector = connector..indent.."</causalConnector>"
	print(connector)
	return connector
end
