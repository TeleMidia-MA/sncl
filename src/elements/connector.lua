local connector = {}

local Connector = {}

function connector.new(id)
   local self = {
      id = id,
      pai = nil,
      linkParams = {},
      conditions = {},
      actions = {},
      tipo = "connector",
   }
   setmetatable(self, {__index = Connector})
   return self
end

function Connector:setNumCondsAndActions (numConds, numActions)
   self.numConds = numConds
   self.numActions = numActions
end

function Connector:addConditions(conditions)
   self.conditions = conditions
end
function Connector:addActions(actions)
   self.actions = actions
end

function Connector:toNCL (indent)
   local NCL = ""
   return NCL
end

return connector
