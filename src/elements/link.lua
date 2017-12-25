local utils = require("utils")
local link = {}
local Link = {}

function link.new(line)
   local self = {
      xconnector = nil,
      temEnd = false,
      pai = nil,
      line = line,
      conditions = {},
      actions = {},
      properties = {},
      _type = "link",
   }
   setmetatable(self, {__index = Link})
   return self
end

function Link:addCondition(condition)
   table.insert(self.conditions, condition)
end
function Link:addAction(action)
   table.insert(self.actions, action)
end
function Link:addPropriedade(nome, valor)
   self.properties[nome] = valor
end

function Link:createConnector()
   -- TODO: create connectorParam for bindParam of conditions

   local condId = ""
   for _, condition in pairs(self.conditions) do
      local cond = condition.condition
      cond = cond:sub(1,1):upper()..cond:sub(2)
      if not condId:find(cond) then
         condId = condId..cond
      else
         condId = condId.."N"
      end
      for prop,_ in pairs(condition.properties) do
         prop = prop:sub(1,1):upper()..prop:sub(2)
         if not condId:find(prop) then
            condId = condId..prop
         end
      end
   end

   local actionId = ""
   for _, action in pairs(self.actions) do
      local act = action.action
      act = act:sub(1,1):upper()..act:sub(2)
      if not actionId:find(act) then
         actionId = actionId..act
      else
         actionId = actionId.."N"
      end
      for prop, _ in pairs(action.properties) do
         prop = prop:sub(1,1):upper()..prop:sub(2)
         if not actionId:find(prop) then
            actionId = actionId..prop
         end
      end
   end

   connId = condId..actionId
   if not symbolTable.connectors[connId] then
      local newConnector = Connector.new(connId)
      newConnector:addConditions(self.conditions)
      newConnector:addActions(self.actions)
      symbolTable.connectors[connId] = newConnector
   end
   self.xconnector = connId
end

function Link:check()
   if self.hasEnd == false then
      utils.printErro("Element Link does not have end", self.line)
      return
   end
   for _, val in pairs(self.conditions) do
      val:check()
   end
   for _, val in pairs(self.actions) do
      val:check()
   end
   self:createConnector()
end

function Link:toNCL(indent)
   local NCL = indent.."<link xconnector=\""..self.xconnector.."\">"

   -- Link Params
   for pos, val in pairs(self.properties) do
      NCL = NCL..indent.."   <linkParam name=\""..pos.."\" value=\""..val.."\"/>"
   end

   -- Conditions
   local hasCondition = false
   for _, val in pairs (self.conditions) do
      NCL = NCL..val:toNCL(indent.."   ")
      hasCondition = true
   end

   -- Actions
   local hasAction = false
   for _, val in pairs(self.actions) do
      NCL = NCL..val:toNCL(indent.."   ")
      hasAction = true
   end
   if not hasCondition or not hasAction then
      utils.printErro("Link element must have at least 1 action and 1 condition", self.line)
      return ""
   end

   NCL = NCL..indent.."</link>"

   return NCL
end

function Link:parsePropriedade(str)
   local name, value = utils.separateSymbol(str)
   if name and value then
      self.properties[name] = value
   end
end

return link
