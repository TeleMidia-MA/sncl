local connector = {}

local Connector = {}

function connector.new(id)
   local self = {
      id = id,
      pai = nil,
      linkParams = {},
      linkConditions = {},
      linkActions = {},
      conditions = {
         n = 0
      },
      actions = {
         n = 0
      },
      tipo = "connector",
   }
   setmetatable(self, {__index = Connector})
   return self
end

function Connector:addActions(actions)
   self.linkActions = actions
end

function Connector:addConditions(conditions)
   self.linkConditions = conditions
end

function Connector:check()
   for _, condition in pairs(self.linkConditions) do

   end

   for _, action in pairs(self.linkActions) do
      local act = action.action
      if not self.actions[act] then
         self.actions[act] = {
            times = 1,
         }
         self.actions.n = self.actions.n+1
         for pos, val in pairs(action.propriedades) do
            self.actions[act][pos] = true
         end
      else
         self.actions[act].times = self.actions[act].times+1
      end
   end
end

function Connector:genCondition(indent)
   local Condition = ""

   for pos, val in pairs(self.conditions) do
      if pos ~= "n" then
         Condition = Condition..indent.."<simpleCondition role=\""..pos.."\""
      end
   end

   return Condition
end

function Connector:genActions(indent)
   local Action = ""
   for pos, val in pairs(self.actions) do
      if pos ~= "n" then
         Action = Action..indent.."<simpleAction role=\""..pos.."\""
         if val.times > 1 then
            Action = Action.." max=\"unbounded\" qualifier=\"par\""
         end
         for prop,_ in pairs(val) do
            if prop ~= "times" then
               Action = Action.." "..prop.."=\"$"..prop.."\""
            end
         end
         Action = Action.."/>"
      end
   end
   return Action
end

function Connector:toNCL (indent)
   local NCL = indent.."<causalConnector id=\""..self.id.."\">"
   if self.conditions.n > 1 then
      NCL = NCL..indent.."   <compoundCondition operator=\"and\">"
      NCL = NCL..self:genCondition(indent.."      ")
      NCL = NCL..indent.."   </compoundCondition>"
   else
      NCL = NCL..self:genCondition(indent.."   ")
   end

   if self.actions.n > 1 then
      NCL = NCL..indent.."   <compoundAction operator=\"seq\">"
      NCL = NCL..self:genActions(indent.."      ")
      NCL = NCL..indent.."   </compoundAction>"
   else
      NCL = NCL..self:genActions(indent.."   ")
   end

   NCL = NCL..indent.."</causalConnector>"
   print(NCL)
   return NCL
end

return connector
